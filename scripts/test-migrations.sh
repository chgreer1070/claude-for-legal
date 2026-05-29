#!/usr/bin/env bash
# Copyright 2026 Anthropic PBC
# SPDX-License-Identifier: Apache-2.0
# Validate the CoCounsel Legal migration chain.
#
# Without PostgreSQL: runs structural checks (SQL syntax heuristics,
# ordering, idempotency guards, schema_migrations bookkeeping).
#
# With PostgreSQL (--live): spins up a temporary database, applies all
# migrations in sequence, and verifies the schema is correct.
#
# Usage:
#   bash scripts/test-migrations.sh           # structural checks only
#   bash scripts/test-migrations.sh --live    # requires psql + createdb
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIG_DIR="$ROOT/external_plugins/cocounsel-legal/db/migrations"
fail=0
mode="structural"

if [[ "${1:-}" == "--live" ]]; then
  mode="live"
fi

echo "=== CoCounsel Legal Migration Validation (mode: $mode) ==="
echo ""

# ---------------------------------------------------------------
# Structural checks (always run, no database needed)
# ---------------------------------------------------------------

echo "--- Structural checks ---"

# 1. Migration files exist and are numbered sequentially
files=($(ls "$MIG_DIR"/*.sql 2>/dev/null | sort))
count=${#files[@]}
if [[ $count -eq 0 ]]; then
  echo "  ✗ No migration files found in $MIG_DIR" >&2
  exit 1
fi
echo "  ✓ Found $count migration files"

prev=0
for f in "${files[@]}"; do
  base=$(basename "$f")
  num=$(echo "$base" | grep -oP '^\d+' | sed 's/^0*//')
  expected=$((prev + 1))
  if [[ "$num" -ne "$expected" ]]; then
    echo "  ✗ Gap in migration numbering: expected $(printf '%03d' $expected), got $base" >&2
    fail=1
  fi
  prev=$num
done
if [[ $fail -eq 0 ]]; then
  echo "  ✓ Migration numbering is sequential (001-$(printf '%03d' $count))"
fi

# 2. Each migration has idempotency guards
for f in "${files[@]}"; do
  base=$(basename "$f")
  if ! grep -q 'schema_migrations' "$f"; then
    echo "  ✗ $base: missing schema_migrations check" >&2
    fail=1
  else
    echo "  ✓ $base: schema_migrations guard present"
  fi

  if ! grep -q 'BEGIN' "$f"; then
    echo "  ✗ $base: missing BEGIN transaction" >&2
    fail=1
  fi

  if ! grep -q 'COMMIT' "$f"; then
    echo "  ✗ $base: missing COMMIT" >&2
    fail=1
  fi
done

# 3. Check for dangerous patterns
for f in "${files[@]}"; do
  base=$(basename "$f")

  # No DROP TABLE without IF EXISTS
  if grep -qP 'DROP\s+TABLE\s+(?!IF)' "$f"; then
    echo "  ✗ $base: DROP TABLE without IF EXISTS" >&2
    fail=1
  fi

  # No TRUNCATE (data loss)
  if grep -qi 'TRUNCATE' "$f"; then
    echo "  ✗ $base: TRUNCATE found (use DELETE or idempotent INSERT)" >&2
    fail=1
  fi

  # No NOW() in partial index WHERE clauses
  if grep -qP 'CREATE\s+INDEX.*WHERE.*NOW\(\)' "$f"; then
    echo "  ✗ $base: NOW() in partial index WHERE clause (evaluated at creation time)" >&2
    fail=1
  fi
done

if [[ $fail -eq 0 ]]; then
  echo "  ✓ No dangerous patterns found"
fi

# 4. Verify INSERT INTO schema_migrations for each migration
for f in "${files[@]}"; do
  base=$(basename "$f")
  num=$(echo "$base" | grep -oP '^\d+' | sed 's/^0*//')
  if ! grep -q "INSERT INTO schema_migrations.*$num" "$f"; then
    echo "  ✗ $base: missing INSERT INTO schema_migrations for version $num" >&2
    fail=1
  fi
done

if [[ $fail -eq 0 ]]; then
  echo "  ✓ All migrations register in schema_migrations"
fi

echo ""

# ---------------------------------------------------------------
# Live checks (only with --live flag and psql available)
# ---------------------------------------------------------------

if [[ "$mode" == "live" ]]; then
  echo "--- Live database checks ---"

  if ! command -v psql &>/dev/null; then
    echo "  ✗ psql not found. Install PostgreSQL client tools." >&2
    exit 1
  fi

  if ! command -v createdb &>/dev/null; then
    echo "  ✗ createdb not found. Install PostgreSQL client tools." >&2
    exit 1
  fi

  DB_NAME="cocounsel_migration_test_$$"
  trap 'dropdb --if-exists "$DB_NAME" 2>/dev/null' EXIT

  echo "  Creating temporary database: $DB_NAME"
  createdb "$DB_NAME"

  # Apply migrations in order
  for f in "${files[@]}"; do
    base=$(basename "$f")
    if psql -d "$DB_NAME" -f "$f" -v ON_ERROR_STOP=1 > /dev/null 2>&1; then
      echo "  ✓ $base: applied successfully"
    else
      echo "  ✗ $base: FAILED to apply" >&2
      fail=1
      break
    fi
  done

  if [[ $fail -eq 0 ]]; then
    # Verify schema_migrations has all entries
    mig_count=$(psql -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM schema_migrations;" 2>/dev/null | tr -d ' ')
    if [[ "$mig_count" -eq "$count" ]]; then
      echo "  ✓ schema_migrations has $mig_count entries (expected $count)"
    else
      echo "  ✗ schema_migrations has $mig_count entries (expected $count)" >&2
      fail=1
    fi

    # Verify key tables exist
    for table in legal_documents citations research_sessions research_reports \
                 jurisdictions practical_law_sources current_awareness \
                 administrative_materials query_log jurisdiction_usage \
                 citation_verification_log research_topics \
                 subscription_quotas usage_counters active_sessions rate_limit_events; do
      exists=$(psql -d "$DB_NAME" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '$table');" 2>/dev/null | tr -d ' ')
      if [[ "$exists" == "t" ]]; then
        echo "  ✓ Table $table exists"
      else
        echo "  ✗ Table $table missing" >&2
        fail=1
      fi
    done

    # Verify jurisdictions were seeded
    jur_count=$(psql -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM jurisdictions;" 2>/dev/null | tr -d ' ')
    if [[ "$jur_count" -ge 70 ]]; then
      echo "  ✓ Jurisdictions seeded: $jur_count rows"
    else
      echo "  ✗ Jurisdictions: only $jur_count rows (expected >= 70)" >&2
      fail=1
    fi

    # Verify DC is territorial, not state
    dc_type=$(psql -d "$DB_NAME" -t -c "SELECT jurisdiction_type FROM jurisdictions WHERE abbreviation = 'DC';" 2>/dev/null | tr -d ' ')
    if [[ "$dc_type" == "territorial" ]]; then
      echo "  ✓ DC classified as 'territorial'"
    else
      echo "  ✗ DC classified as '$dc_type' (expected 'territorial')" >&2
      fail=1
    fi

    # Verify idempotency: re-apply all migrations
    echo "  --- Re-applying all migrations (idempotency check) ---"
    for f in "${files[@]}"; do
      base=$(basename "$f")
      if psql -d "$DB_NAME" -f "$f" -v ON_ERROR_STOP=1 > /dev/null 2>&1; then
        echo "  ✓ $base: idempotent re-apply OK"
      else
        echo "  ✗ $base: FAILED on re-apply (not idempotent)" >&2
        fail=1
      fi
    done
  fi

  echo ""
fi

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------

if [[ $fail -eq 0 ]]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL" >&2
fi
exit $fail
