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
├── westlaw_schema.sql                 ← reference schema (standalone)
├── westlaw_indexes.sql                ← reference indexes (standalone)
└── migrations/
    ├── README.md                      ← migration conventions
    ├── 001_initial_schema.sql         ← core tables
    ├── 002_core_indexes.sql           ← Deep Research access-pattern indexes
    └── 003_query_analytics.sql        ← usage tracking and performance metrics
```

## Data-access pattern analysis

The schema and indexes are derived from the four MCP tool calls in the
Deep Research skill (`skills/deep-research/SKILL.md`):

| Tool | Access pattern | Key tables |
|---|---|---|
| `start_deep_research` | FTS + jurisdiction + doc-type filter | `legal_documents`, `jurisdictions` |
| `check_deep_research_status` | Poll by conversation_id until terminal | `research_sessions` |
| `get_deep_research_report` | Fetch report + resolve citations | `research_reports`, `citations` |
| `follow_up_deep_research` | Append to conversation + new search | `research_reports`, `legal_documents` |

### 1. `legal_research_start_deep_research(query, jurisdictions)`

Starts a new research session. The server fans out across document types
(case law, statutes, regulations, administrative materials, secondary
sources, Practical Law, current awareness) filtered by up to 3
jurisdictions and a natural-language query.

**Hot indexes:**

- `idx_legal_documents_fts` — GIN full-text search on `search_vector`
- `idx_legal_documents_jurisdiction_doc_type` — narrows the FTS bitmap
  by jurisdiction + document type before scoring
- `idx_legal_documents_juris_type_date` — covers the common
  jurisdiction + type + date-range fan-out

### 2. `legal_research_check_deep_research_status(conversation_id)`

Polls a session row until `is_terminal = TRUE`. Called repeatedly with
backoff.

**Hot indexes:**

- `idx_research_sessions_status_poll` — partial index on non-terminal
  sessions for fast poll lookups
- `idx_research_sessions_poll_cover` — covering index that avoids a
  heap fetch during polling

### 3. `legal_research_get_deep_research_report(conversation_id)`

Single-row fetch of the completed report.

**Hot indexes:**

- `idx_research_reports_conversation_id` — direct lookup
- `idx_citations_source_document_id` — resolves inline citations during
  report assembly

### 4. `follow_up_deep_research(conversation_id, query)`

Appends a follow-up research segment to an existing conversation.
Combines session lookup with a new document search scoped to the
original jurisdictions.

**Hot indexes:**

- `idx_research_reports_conversation_seq` — ordered retrieval of all
  report segments in a conversation
- Same document-search indexes as pattern 1

Migration 003 adds analytics tables for tracking query performance,
jurisdiction usage, citation hit rates, and research topic clustering.

## Assumptions

- PostgreSQL 14+ (GIN indexes, `tsvector`, partial indexes).
- The `search_vector` column is maintained by a trigger on
  `title`, `headnotes`, and `body_text` (defined in the schema file).
- Jurisdiction values are normalized through the `jurisdictions`
  reference table before use in queries.
