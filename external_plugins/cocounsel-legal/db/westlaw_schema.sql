-- ---------------------------------------------------------------------------
-- Westlaw Database Schema for CoCounsel Legal Plugin
-- ---------------------------------------------------------------------------
--
-- Reference schema for the tables accessed by the CoCounsel Legal Deep
-- Research workflow.  Each table maps to a data domain surfaced through the
-- MCP tools defined in skills/deep-research/SKILL.md.
--
-- Assumes PostgreSQL 14+.
-- ---------------------------------------------------------------------------

BEGIN;

-- =========================================================================
-- 1. Jurisdictions — reference table
-- =========================================================================

CREATE TABLE IF NOT EXISTS jurisdictions (
    id              SERIAL PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,       -- e.g. "California"
    abbreviation    TEXT NOT NULL UNIQUE,       -- e.g. "CA"
    jurisdiction_type TEXT NOT NULL             -- federal | state | territorial
        CHECK (jurisdiction_type IN ('federal', 'state', 'territorial')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================================
-- 2. Legal documents — case law, statutes, regulations, etc.
-- =========================================================================

CREATE TABLE IF NOT EXISTS legal_documents (
    id              BIGSERIAL PRIMARY KEY,
    westlaw_key     TEXT UNIQUE,                -- Westlaw document identifier
    document_type   TEXT NOT NULL
        CHECK (document_type IN (
            'case_law', 'statute', 'regulation',
            'administrative_material', 'secondary_source',
            'practical_law', 'current_awareness'
        )),
    title           TEXT NOT NULL,
    jurisdiction    TEXT NOT NULL
        REFERENCES jurisdictions(name),
    court           TEXT,                       -- e.g. "9th Cir.", "Cal. Sup. Ct."
    decided_date    DATE,                       -- date of decision / enactment
    effective_date  DATE,                       -- statutes / regulations
    citation        TEXT,                       -- canonical cite string
    body_text       TEXT,                       -- full text
    headnotes       TEXT,                       -- Westlaw headnotes / key numbers
    search_vector   TSVECTOR,                   -- pre-computed FTS vector
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-maintain search_vector from title + headnotes + body_text.
CREATE OR REPLACE FUNCTION legal_documents_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.headnotes, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.body_text, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_legal_documents_search_vector
    BEFORE INSERT OR UPDATE OF title, headnotes, body_text
    ON legal_documents
    FOR EACH ROW
    EXECUTE FUNCTION legal_documents_search_vector_update();

-- =========================================================================
-- 3. Citations — cross-references between legal documents
-- =========================================================================

CREATE TABLE IF NOT EXISTS citations (
    id                  BIGSERIAL PRIMARY KEY,
    source_document_id  BIGINT NOT NULL REFERENCES legal_documents(id),
    cited_document_id   BIGINT REFERENCES legal_documents(id),
    cite_string         TEXT NOT NULL,          -- e.g. "123 F.3d 456"
    westlaw_key         TEXT,                   -- resolved Westlaw key
    pin_cite            TEXT,                   -- page / paragraph pin
    treatment           TEXT,                   -- followed | distinguished | overruled …
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================================
-- 4. Research sessions — conversation lifecycle
-- =========================================================================

CREATE TABLE IF NOT EXISTS research_sessions (
    id              BIGSERIAL PRIMARY KEY,
    conversation_id UUID NOT NULL UNIQUE,
    user_id         TEXT NOT NULL,
    query           TEXT NOT NULL,
    jurisdictions   TEXT[] NOT NULL DEFAULT '{}',
    status          TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'in_progress', 'complete', 'failed')),
    is_terminal     BOOLEAN NOT NULL DEFAULT FALSE,
    percent_complete INTEGER NOT NULL DEFAULT 0
        CHECK (percent_complete BETWEEN 0 AND 100),
    error_type      TEXT,
    failure_reason  TEXT,
    research_plan   JSONB,
    next_action_poll_backoff_ms INTEGER NOT NULL DEFAULT 10000,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================================
-- 5. Research reports — completed output
-- =========================================================================

CREATE TABLE IF NOT EXISTS research_reports (
    id              BIGSERIAL PRIMARY KEY,
    conversation_id UUID NOT NULL
        REFERENCES research_sessions(conversation_id),
    sequence_number INTEGER NOT NULL DEFAULT 1,   -- 1 = initial, 2+ = follow-ups
    answer_text     TEXT NOT NULL,                 -- markdown / HTML report body
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (conversation_id, sequence_number)
);

-- =========================================================================
-- 6. Practical Law sources
-- =========================================================================

CREATE TABLE IF NOT EXISTS practical_law_sources (
    id              BIGSERIAL PRIMARY KEY,
    westlaw_key     TEXT UNIQUE,
    title           TEXT NOT NULL,
    topic           TEXT NOT NULL,
    jurisdiction    TEXT
        REFERENCES jurisdictions(name),
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

-- =========================================================================
-- 7. Current awareness — JD Supra and news content
-- =========================================================================

CREATE TABLE IF NOT EXISTS current_awareness (
    id              BIGSERIAL PRIMARY KEY,
    title           TEXT NOT NULL,
    source          TEXT NOT NULL,               -- e.g. "JD Supra"
    author          TEXT,
    published_date  DATE NOT NULL,
    topic_tags      TEXT[] NOT NULL DEFAULT '{}',
    jurisdiction    TEXT
        REFERENCES jurisdictions(name),
    body_text       TEXT,
    url             TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================================
-- 8. Administrative materials — agency decisions, rulings, guidance
-- =========================================================================

CREATE TABLE IF NOT EXISTS administrative_materials (
    id              BIGSERIAL PRIMARY KEY,
    westlaw_key     TEXT UNIQUE,
    title           TEXT NOT NULL,
    agency          TEXT NOT NULL,               -- e.g. "SEC", "FTC", "NLRB"
    jurisdiction    TEXT NOT NULL
        REFERENCES jurisdictions(name),
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

COMMIT;
