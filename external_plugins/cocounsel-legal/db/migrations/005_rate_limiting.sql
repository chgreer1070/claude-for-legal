-- ---------------------------------------------------------------------------
-- Migration 005: Rate limiting and quota tracking
-- ---------------------------------------------------------------------------
-- Tracks API usage against CoCounsel Legal subscription limits.
-- ---------------------------------------------------------------------------

BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = 5) THEN
        RAISE NOTICE 'Migration 005 already applied — skipping';
        RETURN;
    END IF;

    -- Per-user subscription quotas
    CREATE TABLE subscription_quotas (
        id              SERIAL PRIMARY KEY,
        user_id         TEXT NOT NULL UNIQUE,
        plan_name       TEXT NOT NULL DEFAULT 'standard',
        daily_limit     INTEGER NOT NULL DEFAULT 50,
        monthly_limit   INTEGER NOT NULL DEFAULT 500,
        concurrent_limit INTEGER NOT NULL DEFAULT 3,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX idx_subscription_quotas_user
        ON subscription_quotas (user_id);

    -- Usage counters — rolling windows
    CREATE TABLE usage_counters (
        id              BIGSERIAL PRIMARY KEY,
        user_id         TEXT NOT NULL,
        period_type     TEXT NOT NULL
            CHECK (period_type IN ('daily', 'monthly')),
        period_start    DATE NOT NULL,
        request_count   INTEGER NOT NULL DEFAULT 0,
        last_request_at TIMESTAMPTZ,
        UNIQUE (user_id, period_type, period_start)
    );

    CREATE INDEX idx_usage_counters_user_period
        ON usage_counters (user_id, period_type, period_start DESC);

    -- Active sessions for concurrent-limit enforcement
    CREATE TABLE active_sessions (
        id              BIGSERIAL PRIMARY KEY,
        user_id         TEXT NOT NULL,
        conversation_id UUID NOT NULL UNIQUE
            REFERENCES research_sessions(conversation_id),
        started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        last_poll_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX idx_active_sessions_user
        ON active_sessions (user_id);

    -- Stale session cleanup: query with WHERE last_poll_at < NOW() - '30 min'
    -- Uses a plain B-tree (not a partial index) because NOW() in a partial
    -- index WHERE clause is evaluated once at creation time, not at query time.
    CREATE INDEX idx_active_sessions_last_poll
        ON active_sessions (last_poll_at);

    -- Rate limit events log (for alerting and dashboards)
    CREATE TABLE rate_limit_events (
        id              BIGSERIAL PRIMARY KEY,
        user_id         TEXT NOT NULL,
        event_type      TEXT NOT NULL
            CHECK (event_type IN (
                'daily_limit_reached',
                'monthly_limit_reached',
                'concurrent_limit_reached',
                'throttled'
            )),
        request_count   INTEGER,
        limit_value     INTEGER,
        occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX idx_rate_limit_events_user
        ON rate_limit_events (user_id, occurred_at DESC);

    CREATE INDEX idx_rate_limit_events_type
        ON rate_limit_events (event_type, occurred_at DESC);

    INSERT INTO schema_migrations (version, name) VALUES (5, '005_rate_limiting');
END;
$$;

COMMIT;
