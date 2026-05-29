-- ---------------------------------------------------------------------------
-- Migration 002: Core indexes for Deep Research access patterns
-- ---------------------------------------------------------------------------
-- Adds indexes optimized for the four MCP tool calls:
--   start_deep_research, check_status, get_report, follow_up
-- ---------------------------------------------------------------------------

BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = 2) THEN
        RAISE NOTICE 'Migration 002 already applied — skipping';
        RETURN;
    END IF;

    -- Research sessions — poll hot path
    CREATE INDEX idx_research_sessions_conversation_id
        ON research_sessions (conversation_id);
    CREATE INDEX idx_research_sessions_status_poll
        ON research_sessions (conversation_id, is_terminal)
        WHERE is_terminal = FALSE;
    CREATE INDEX idx_research_sessions_status
        ON research_sessions (status, created_at);
    CREATE INDEX idx_research_sessions_created_at
        ON research_sessions (created_at);
    CREATE INDEX idx_research_sessions_poll_cover
        ON research_sessions (conversation_id, status, is_terminal, updated_at);

    -- Legal documents — search and filter
    CREATE INDEX idx_legal_documents_jurisdiction
        ON legal_documents (jurisdiction);
    CREATE INDEX idx_legal_documents_doc_type
        ON legal_documents (document_type);
    CREATE INDEX idx_legal_documents_jurisdiction_doc_type
        ON legal_documents (jurisdiction, document_type);
    CREATE INDEX idx_legal_documents_jurisdiction_decided_date
        ON legal_documents (jurisdiction, decided_date DESC);
    CREATE INDEX idx_legal_documents_fts
        ON legal_documents USING GIN (search_vector);
    CREATE INDEX idx_legal_documents_jurisdiction_fts
        ON legal_documents USING GIN (search_vector)
        WHERE jurisdiction IS NOT NULL;
    CREATE INDEX idx_legal_documents_juris_type_date
        ON legal_documents (jurisdiction, document_type, decided_date DESC);

    -- Citations
    CREATE INDEX idx_citations_cite_string
        ON citations (cite_string);
    CREATE INDEX idx_citations_westlaw_key
        ON citations (westlaw_key);
    CREATE INDEX idx_citations_source_document_id
        ON citations (source_document_id);
    CREATE INDEX idx_citations_cited_document_id
        ON citations (cited_document_id);

    -- Jurisdictions
    CREATE INDEX idx_jurisdictions_name
        ON jurisdictions (LOWER(name));
    CREATE INDEX idx_jurisdictions_abbreviation
        ON jurisdictions (abbreviation);

    -- Research reports
    CREATE INDEX idx_research_reports_conversation_id
        ON research_reports (conversation_id);
    CREATE INDEX idx_research_reports_conversation_seq
        ON research_reports (conversation_id, sequence_number);

    -- Practical Law sources
    CREATE INDEX idx_practical_law_topic
        ON practical_law_sources (topic);
    CREATE INDEX idx_practical_law_jurisdiction
        ON practical_law_sources (jurisdiction);
    CREATE INDEX idx_practical_law_topic_jurisdiction
        ON practical_law_sources (topic, jurisdiction);
    CREATE INDEX idx_practical_law_resource_type
        ON practical_law_sources (resource_type);

    -- Current awareness
    CREATE INDEX idx_current_awareness_published_date
        ON current_awareness (published_date DESC);
    CREATE INDEX idx_current_awareness_source_date
        ON current_awareness (source, published_date DESC);
    CREATE INDEX idx_current_awareness_topic
        ON current_awareness USING GIN (topic_tags);

    -- Administrative materials
    CREATE INDEX idx_admin_materials_agency
        ON administrative_materials (agency);
    CREATE INDEX idx_admin_materials_agency_date
        ON administrative_materials (agency, issued_date DESC);
    CREATE INDEX idx_admin_materials_jurisdiction_agency
        ON administrative_materials (jurisdiction, agency);

    INSERT INTO schema_migrations (version, name) VALUES (2, '002_core_indexes');
END;
$$;

COMMIT;
