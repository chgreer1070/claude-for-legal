-- ---------------------------------------------------------------------------
-- Migration 001: Initial Westlaw schema for CoCounsel Legal
-- ---------------------------------------------------------------------------
-- Creates the core tables that back the Deep Research workflow.
-- Apply with: psql -d $DB -f 001_initial_schema.sql
-- ---------------------------------------------------------------------------

BEGIN;

-- Migration tracking
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    applied_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Guard: skip if already applied
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = 1) THEN
        RAISE NOTICE 'Migration 001 already applied — skipping';
        RETURN;
    END IF;

    -- Jurisdictions
    CREATE TABLE jurisdictions (
        id                SERIAL PRIMARY KEY,
        name              TEXT NOT NULL UNIQUE,
        abbreviation      TEXT NOT NULL UNIQUE,
        jurisdiction_type TEXT NOT NULL
            CHECK (jurisdiction_type IN ('federal', 'state', 'territorial')),
        created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- Legal documents
    CREATE TABLE legal_documents (
        id              BIGSERIAL PRIMARY KEY,
        westlaw_key     TEXT UNIQUE,
        document_type   TEXT NOT NULL
            CHECK (document_type IN (
                'case_law', 'statute', 'regulation',
                'administrative_material', 'secondary_source',
                'practical_law', 'current_awareness'
            )),
        title           TEXT NOT NULL,
        jurisdiction    TEXT NOT NULL REFERENCES jurisdictions(name),
        court           TEXT,
        decided_date    DATE,
        effective_date  DATE,
        citation        TEXT,
        body_text       TEXT,
        headnotes       TEXT,
        search_vector   TSVECTOR,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE FUNCTION legal_documents_search_vector_update() RETURNS TRIGGER AS $t$
    BEGIN
        NEW.search_vector :=
            setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
            setweight(to_tsvector('english', COALESCE(NEW.headnotes, '')), 'B') ||
            setweight(to_tsvector('english', COALESCE(NEW.body_text, '')), 'C');
        RETURN NEW;
    END;
    $t$ LANGUAGE plpgsql;

    CREATE TRIGGER trg_legal_documents_search_vector
        BEFORE INSERT OR UPDATE OF title, headnotes, body_text
        ON legal_documents
        FOR EACH ROW
        EXECUTE FUNCTION legal_documents_search_vector_update();

    -- Citations
    CREATE TABLE citations (
        id                  BIGSERIAL PRIMARY KEY,
        source_document_id  BIGINT NOT NULL REFERENCES legal_documents(id),
        cited_document_id   BIGINT REFERENCES legal_documents(id),
        cite_string         TEXT NOT NULL,
        westlaw_key         TEXT,
        pin_cite            TEXT,
        treatment           TEXT,
        created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- Research sessions
    CREATE TABLE research_sessions (
        id                          BIGSERIAL PRIMARY KEY,
        conversation_id             UUID NOT NULL UNIQUE,
        user_id                     TEXT NOT NULL,
        query                       TEXT NOT NULL,
        jurisdictions               TEXT[] NOT NULL DEFAULT '{}',
        status                      TEXT NOT NULL DEFAULT 'pending'
            CHECK (status IN ('pending', 'in_progress', 'complete', 'failed')),
        is_terminal                 BOOLEAN NOT NULL DEFAULT FALSE,
        percent_complete            INTEGER NOT NULL DEFAULT 0
            CHECK (percent_complete BETWEEN 0 AND 100),
        error_type                  TEXT,
        failure_reason              TEXT,
        research_plan               JSONB,
        next_action_poll_backoff_ms INTEGER NOT NULL DEFAULT 10000,
        created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- Research reports
    CREATE TABLE research_reports (
        id              BIGSERIAL PRIMARY KEY,
        conversation_id UUID NOT NULL
            REFERENCES research_sessions(conversation_id),
        sequence_number INTEGER NOT NULL DEFAULT 1,
        answer_text     TEXT NOT NULL,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (conversation_id, sequence_number)
    );

    -- Practical Law sources
    CREATE TABLE practical_law_sources (
        id              BIGSERIAL PRIMARY KEY,
        westlaw_key     TEXT UNIQUE,
        title           TEXT NOT NULL,
        topic           TEXT NOT NULL,
        jurisdiction    TEXT REFERENCES jurisdictions(name),
        resource_type   TEXT NOT NULL
            CHECK (resource_type IN (
                'practice_note', 'standard_document', 'checklist',
                'toolkit', 'legal_update', 'article'
            )),
        body_text       TEXT,
        published_date  DATE,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- Current awareness
    CREATE TABLE current_awareness (
        id              BIGSERIAL PRIMARY KEY,
        title           TEXT NOT NULL,
        source          TEXT NOT NULL,
        author          TEXT,
        published_date  DATE NOT NULL,
        topic_tags      TEXT[] NOT NULL DEFAULT '{}',
        jurisdiction    TEXT REFERENCES jurisdictions(name),
        body_text       TEXT,
        url             TEXT,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- Administrative materials
    CREATE TABLE administrative_materials (
        id              BIGSERIAL PRIMARY KEY,
        westlaw_key     TEXT UNIQUE,
        title           TEXT NOT NULL,
        agency          TEXT NOT NULL,
        jurisdiction    TEXT NOT NULL REFERENCES jurisdictions(name),
        material_type   TEXT NOT NULL
            CHECK (material_type IN (
                'decision', 'ruling', 'guidance',
                'advisory_opinion', 'no_action_letter', 'order'
            )),
        issued_date     DATE,
        body_text       TEXT,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    INSERT INTO schema_migrations (version, name) VALUES (1, '001_initial_schema');
END;
$$;

COMMIT;
