-- ---------------------------------------------------------------------------
-- Migration 003: Query analytics for research performance tracking
-- ---------------------------------------------------------------------------
-- Adds tables and indexes for tracking research query patterns, response
-- times, citation hit rates, and usage by jurisdiction / topic.
-- ---------------------------------------------------------------------------

BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = 3) THEN
        RAISE NOTICE 'Migration 003 already applied — skipping';
        RETURN;
    END IF;

    -- -----------------------------------------------------------------
    -- Query log: every MCP tool call with timing
    -- -----------------------------------------------------------------
    CREATE TABLE query_log (
        id              BIGSERIAL PRIMARY KEY,
        conversation_id UUID REFERENCES research_sessions(conversation_id),
        tool_name       TEXT NOT NULL
            CHECK (tool_name IN (
                'start_deep_research',
                'check_deep_research_status',
                'get_deep_research_report',
                'follow_up_deep_research'
            )),
        query_text      TEXT,
        jurisdictions   TEXT[] DEFAULT '{}',
        started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        completed_at    TIMESTAMPTZ,
        duration_ms     INTEGER GENERATED ALWAYS AS (
            EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000
        ) STORED,
        status_code     TEXT,
        error_message   TEXT
    );

    -- Tool call frequency and latency analysis
    CREATE INDEX idx_query_log_tool_name
        ON query_log (tool_name, started_at DESC);

    -- Per-session query timeline
    CREATE INDEX idx_query_log_conversation
        ON query_log (conversation_id, started_at);

    -- Slow-query identification
    CREATE INDEX idx_query_log_duration
        ON query_log (duration_ms DESC NULLS LAST)
        WHERE completed_at IS NOT NULL;

    -- Error rate tracking
    CREATE INDEX idx_query_log_errors
        ON query_log (tool_name, started_at DESC)
        WHERE status_code != 'success';

    -- -----------------------------------------------------------------
    -- Jurisdiction usage: track which jurisdictions are queried most
    -- -----------------------------------------------------------------
    CREATE TABLE jurisdiction_usage (
        id              BIGSERIAL PRIMARY KEY,
        jurisdiction    TEXT NOT NULL REFERENCES jurisdictions(name),
        query_count     INTEGER NOT NULL DEFAULT 0,
        last_queried_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        avg_duration_ms NUMERIC(10, 2),
        period_start    DATE NOT NULL,
        period_end      DATE NOT NULL
    );

    CREATE INDEX idx_jurisdiction_usage_jurisdiction
        ON jurisdiction_usage (jurisdiction, period_start DESC);

    CREATE INDEX idx_jurisdiction_usage_period
        ON jurisdiction_usage (period_start, period_end);

    CREATE UNIQUE INDEX idx_jurisdiction_usage_unique_period
        ON jurisdiction_usage (jurisdiction, period_start, period_end);

    -- -----------------------------------------------------------------
    -- Citation hit rates: track which citations are resolved vs missed
    -- -----------------------------------------------------------------
    CREATE TABLE citation_verification_log (
        id              BIGSERIAL PRIMARY KEY,
        conversation_id UUID REFERENCES research_sessions(conversation_id),
        cite_string     TEXT NOT NULL,
        citation_type   TEXT NOT NULL
            CHECK (citation_type IN (
                'case_law', 'statute', 'regulation',
                'administrative', 'secondary'
            )),
        resolved        BOOLEAN NOT NULL,
        treatment       TEXT,
        verified_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX idx_citation_verification_conversation
        ON citation_verification_log (conversation_id);

    -- Unresolved citation tracking for data quality monitoring
    CREATE INDEX idx_citation_verification_unresolved
        ON citation_verification_log (cite_string, verified_at DESC)
        WHERE resolved = FALSE;

    -- Treatment distribution analysis
    CREATE INDEX idx_citation_verification_treatment
        ON citation_verification_log (treatment, verified_at DESC)
        WHERE treatment IS NOT NULL;

    -- -----------------------------------------------------------------
    -- Research topic clustering: track topics for query optimization
    -- -----------------------------------------------------------------
    CREATE TABLE research_topics (
        id              BIGSERIAL PRIMARY KEY,
        conversation_id UUID NOT NULL REFERENCES research_sessions(conversation_id),
        topic_label     TEXT NOT NULL,
        practice_area   TEXT,
        keywords        TEXT[] DEFAULT '{}',
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX idx_research_topics_label
        ON research_topics (topic_label);

    CREATE INDEX idx_research_topics_practice_area
        ON research_topics (practice_area)
        WHERE practice_area IS NOT NULL;

    CREATE INDEX idx_research_topics_keywords
        ON research_topics USING GIN (keywords);

    CREATE INDEX idx_research_topics_conversation
        ON research_topics (conversation_id);

    -- -----------------------------------------------------------------
    -- Materialized view: daily research summary dashboard
    -- -----------------------------------------------------------------
    CREATE MATERIALIZED VIEW IF NOT EXISTS daily_research_summary AS
    SELECT
        DATE(rs.created_at) AS research_date,
        COUNT(*)            AS total_sessions,
        COUNT(*) FILTER (WHERE rs.status = 'complete')  AS completed,
        COUNT(*) FILTER (WHERE rs.status = 'failed')    AS failed,
        AVG(EXTRACT(EPOCH FROM (rs.updated_at - rs.created_at)))
            FILTER (WHERE rs.status = 'complete')       AS avg_completion_secs,
        array_agg(DISTINCT j) FILTER (WHERE j IS NOT NULL) AS jurisdictions_used
    FROM research_sessions rs
    LEFT JOIN LATERAL unnest(rs.jurisdictions) AS j ON TRUE
    GROUP BY DATE(rs.created_at);

    CREATE UNIQUE INDEX idx_daily_research_summary_date
        ON daily_research_summary (research_date);

    INSERT INTO schema_migrations (version, name) VALUES (3, '003_query_analytics');
END;
$$;

COMMIT;
