-- ---------------------------------------------------------------------------
-- Westlaw Database Index Definitions for CoCounsel Legal Plugin
-- ---------------------------------------------------------------------------
--
-- These indexes are derived from the data-access patterns of the CoCounsel
-- Legal plugin's Deep Research workflow (see skills/deep-research/SKILL.md).
--
-- Access patterns optimized:
--   1. legal_research_start_deep_research(query, jurisdictions)
--      → full-text search on legal documents filtered by jurisdiction(s)
--   2. legal_research_check_deep_research_status(conversation_id)
--      → poll a research session by ID; filter on terminal/non-terminal status
--   3. legal_research_get_deep_research_report(conversation_id)
--      → fetch the completed report for a session
--   4. follow_up_deep_research(conversation_id, query)
--      → continue research within an existing session
--
-- Assumes PostgreSQL 14+. Adapt GIN/GiST operators for other engines.
-- ---------------------------------------------------------------------------

BEGIN;

-- =========================================================================
-- 1. Research sessions — the conversation lifecycle
-- =========================================================================
-- Every Deep Research run creates a session row that is polled until
-- is_terminal flips to TRUE, then the report is fetched once.

CREATE INDEX IF NOT EXISTS idx_research_sessions_conversation_id
    ON research_sessions (conversation_id);

-- Status polling: the plugin calls check_deep_research_status in a loop
-- until is_terminal = TRUE.  This covers the WHERE conversation_id = $1
-- AND is_terminal = FALSE hot path.
CREATE INDEX IF NOT EXISTS idx_research_sessions_status_poll
    ON research_sessions (conversation_id, is_terminal)
    WHERE is_terminal = FALSE;

-- Cleanup / admin: find sessions by status (e.g. purging stale 'failed'
-- sessions or reporting on 'complete' throughput).
CREATE INDEX IF NOT EXISTS idx_research_sessions_status
    ON research_sessions (status, created_at);

-- Session age queries (retention, SLA dashboards).
CREATE INDEX IF NOT EXISTS idx_research_sessions_created_at
    ON research_sessions (created_at);

-- =========================================================================
-- 2. Legal documents — the core content searched during research
-- =========================================================================
-- start_deep_research fans out searches across document types and
-- jurisdictions.  The indexes below cover the primary filter dimensions.

-- Jurisdiction filter: every query targets up to 3 jurisdictions.
CREATE INDEX IF NOT EXISTS idx_legal_documents_jurisdiction
    ON legal_documents (jurisdiction);

-- Document-type filter: case_law | statute | regulation |
-- administrative_material | secondary_source | practical_law |
-- current_awareness.
CREATE INDEX IF NOT EXISTS idx_legal_documents_doc_type
    ON legal_documents (document_type);

-- Composite: jurisdiction + document type — the most selective non-text
-- filter combination.
CREATE INDEX IF NOT EXISTS idx_legal_documents_jurisdiction_doc_type
    ON legal_documents (jurisdiction, document_type);

-- Temporal filter: "since 2020"-style date ranges scoped to a jurisdiction.
CREATE INDEX IF NOT EXISTS idx_legal_documents_jurisdiction_decided_date
    ON legal_documents (jurisdiction, decided_date DESC);

-- Full-text search: GIN index on a tsvector column that covers titles,
-- headnotes, and body text so pg_trgm or ts_rank queries are fast.
CREATE INDEX IF NOT EXISTS idx_legal_documents_fts
    ON legal_documents USING GIN (search_vector);

-- Combined text + jurisdiction: allows the planner to intersect the FTS
-- bitmap with a jurisdiction filter in a single scan when the jurisdiction
-- list is narrow (≤ 3 values).
CREATE INDEX IF NOT EXISTS idx_legal_documents_jurisdiction_fts
    ON legal_documents USING GIN (search_vector)
    WHERE jurisdiction IS NOT NULL;

-- =========================================================================
-- 3. Citations — link resolution for inline Westlaw / Practical Law cites
-- =========================================================================
-- Deep Research reports contain inline anchor citations
-- (e.g. <a href="...">Smith v. Jones, 123 F.3d 456</a>).  The MCP server
-- resolves these during report generation.

-- Standard citation string lookup (e.g. "123 F.3d 456").
CREATE INDEX IF NOT EXISTS idx_citations_cite_string
    ON citations (cite_string);

-- Westlaw-key lookup: resolves the cite_string to a Westlaw document URL.
CREATE INDEX IF NOT EXISTS idx_citations_westlaw_key
    ON citations (westlaw_key);

-- Source-document → cited-document join (fan-out during report assembly).
CREATE INDEX IF NOT EXISTS idx_citations_source_document_id
    ON citations (source_document_id);

-- Cited-document reverse lookup (find all documents that cite a given case).
CREATE INDEX IF NOT EXISTS idx_citations_cited_document_id
    ON citations (cited_document_id);

-- =========================================================================
-- 4. Jurisdictions — reference table for the ≤ 3-jurisdiction constraint
-- =========================================================================
-- The plugin validates jurisdiction names before starting research.

CREATE INDEX IF NOT EXISTS idx_jurisdictions_name
    ON jurisdictions (LOWER(name));

CREATE INDEX IF NOT EXISTS idx_jurisdictions_abbreviation
    ON jurisdictions (abbreviation);

-- =========================================================================
-- 5. Research reports — completed output stored for retrieval & follow-up
-- =========================================================================
-- get_deep_research_report fetches the report once; follow_up_deep_research
-- appends to the same conversation.

CREATE INDEX IF NOT EXISTS idx_research_reports_conversation_id
    ON research_reports (conversation_id);

-- Follow-up ordering: multiple report segments per conversation, ordered
-- by sequence.
CREATE INDEX IF NOT EXISTS idx_research_reports_conversation_seq
    ON research_reports (conversation_id, sequence_number);

-- =========================================================================
-- 6. Practical Law sources — secondary-source lookups referenced in reports
-- =========================================================================

CREATE INDEX IF NOT EXISTS idx_practical_law_topic
    ON practical_law_sources (topic);

CREATE INDEX IF NOT EXISTS idx_practical_law_jurisdiction
    ON practical_law_sources (jurisdiction);

CREATE INDEX IF NOT EXISTS idx_practical_law_topic_jurisdiction
    ON practical_law_sources (topic, jurisdiction);

-- Resource-type filter (practice note, standard document, checklist, …).
CREATE INDEX IF NOT EXISTS idx_practical_law_resource_type
    ON practical_law_sources (resource_type);

-- =========================================================================
-- 7. Current awareness — JD Supra and news content
-- =========================================================================

-- Temporal scan: current-awareness queries are almost always date-bounded.
CREATE INDEX IF NOT EXISTS idx_current_awareness_published_date
    ON current_awareness (published_date DESC);

-- Source + date: filter by provider (e.g. JD Supra) within a date window.
CREATE INDEX IF NOT EXISTS idx_current_awareness_source_date
    ON current_awareness (source, published_date DESC);

-- Topic tag lookup.
CREATE INDEX IF NOT EXISTS idx_current_awareness_topic
    ON current_awareness USING GIN (topic_tags);

-- =========================================================================
-- 8. Administrative materials — agency decisions, rulings, guidance
-- =========================================================================

CREATE INDEX IF NOT EXISTS idx_admin_materials_agency
    ON administrative_materials (agency);

CREATE INDEX IF NOT EXISTS idx_admin_materials_agency_date
    ON administrative_materials (agency, issued_date DESC);

CREATE INDEX IF NOT EXISTS idx_admin_materials_jurisdiction_agency
    ON administrative_materials (jurisdiction, agency);

-- =========================================================================
-- 9. Composite covering indexes for the most frequent query shapes
-- =========================================================================

-- Hot path: jurisdiction + document type + date range.  Covers the majority
-- of Deep Research fan-out queries after the initial FTS pass.
CREATE INDEX IF NOT EXISTS idx_legal_documents_juris_type_date
    ON legal_documents (jurisdiction, document_type, decided_date DESC);

-- Session + status + last-updated: the poller reads the session row, checks
-- status, and uses updated_at to compute backoff.
CREATE INDEX IF NOT EXISTS idx_research_sessions_poll_cover
    ON research_sessions (conversation_id, status, is_terminal, updated_at);

COMMIT;
