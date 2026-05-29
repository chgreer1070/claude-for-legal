# Westlaw Database for CoCounsel Legal

Versioned database schema optimized for the CoCounsel Legal plugin's
data access patterns. Uses PostgreSQL 14+.

## Quick start

```bash
# Apply all migrations in order
for f in migrations/0*.sql; do
    psql -d "$WESTLAW_DB" -f "$f"
done
```

## Structure

```
db/
├── README.md                          ← this file
└── migrations/
    ├── README.md                      ← migration conventions
    ├── 001_initial_schema.sql         ← core tables
    ├── 002_core_indexes.sql           ← Deep Research access-pattern indexes
    └── 003_query_analytics.sql        ← usage tracking and performance metrics
```

## Data-access patterns

The schema and indexes are derived from the four MCP tool calls in the
Deep Research skill:

| Tool | Access pattern | Key tables |
|---|---|---|
| `start_deep_research` | FTS + jurisdiction + doc-type filter | `legal_documents`, `jurisdictions` |
| `check_deep_research_status` | Poll by conversation_id until terminal | `research_sessions` |
| `get_deep_research_report` | Fetch report + resolve citations | `research_reports`, `citations` |
| `follow_up_deep_research` | Append to conversation + new search | `research_reports`, `legal_documents` |

Migration 003 adds analytics tables for tracking query performance,
jurisdiction usage, citation hit rates, and research topic clustering.
