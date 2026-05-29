# Database Migrations

Versioned migrations for the CoCounsel Legal Westlaw database.

## Running migrations

Apply in order against a PostgreSQL 14+ database:

```bash
for f in external_plugins/cocounsel-legal/db/migrations/0*.sql; do
    echo "Applying $f …"
    psql -d "$WESTLAW_DB" -f "$f"
done
```

Each migration is idempotent — safe to re-run. The `schema_migrations`
table tracks which versions have been applied.

## Migrations

| Version | Name | Description |
|---|---|---|
| 001 | `initial_schema` | Core tables: jurisdictions, legal_documents, citations, research_sessions, research_reports, practical_law_sources, current_awareness, administrative_materials |
| 002 | `core_indexes` | Performance indexes for the four Deep Research MCP tool access patterns |
| 003 | `query_analytics` | Query logging, jurisdiction usage tracking, citation verification logs, research topic clustering, daily summary materialized view |
| 004 | `seed_jurisdictions` | Populates jurisdictions table: 50 states, DC, 5 territories, 15 federal courts (circuits + SCOTUS) |
| 005 | `rate_limiting` | Subscription quotas, usage counters, active session tracking, rate limit event logging |

## Adding a new migration

1. Create `NNN_descriptive_name.sql` (zero-padded 3-digit version)
2. Wrap in `BEGIN; ... COMMIT;` with the idempotency guard pattern
3. Insert into `schema_migrations` at the end of the `DO` block
4. Update this README
