---
name: cocounsel-legal:quota-tracker
version: 0.1.0
description: >
  Use this skill when a user wants to check their CoCounsel Legal API
  usage, remaining quota, or rate limit status. Use when the user says
  "how many research queries do I have left", "check my usage", "am I
  near my limit", or "show my API quota." Also invoked automatically
  when a rate limit is hit during a research operation.
allowed-tools:
  - mcp
  - Bash
---

# Quota Tracker

Tracks and reports API usage against CoCounsel Legal subscription
limits. Helps users monitor consumption, avoid hitting rate limits,
and plan research batches within quota.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. The rate-limiting
tables from migration 005 must be applied to the database.

## When to Use

- User asks about their remaining API quota or usage
- User wants to see how many research queries they've run today/this
  month
- A rate limit is hit during a research operation
- User wants to plan a batch of research queries and needs to know
  remaining capacity
- User asks about concurrent session limits

## When Not to Use

- Running research — use `cocounsel-legal:deep-research`
- General billing questions — direct to CoCounsel support

## Workflow

### 1. Determine the request

| Request type | What to show |
|---|---|
| "Check my usage" | Current period counts vs. limits |
| "How many queries left?" | Remaining daily and monthly quota |
| "Am I near my limit?" | Percentage consumed + projection |
| Rate limit hit | Which limit was hit, when it resets |
| "Plan a batch" | Available capacity for planned queries |

### 2. Retrieve usage data

Query the rate-limiting tables:
- `subscription_quotas` — the user's plan limits
- `usage_counters` — current daily and monthly counts
- `active_sessions` — concurrent session count
- `rate_limit_events` — recent limit hits

### 3. Present usage summary

```
## CoCounsel Legal Usage

| Metric | Used | Limit | Remaining |
|---|---|---|---|
| Today | 12 | 50 | 38 |
| This month | 187 | 500 | 313 |
| Active sessions | 1 | 3 | 2 |

Last rate limit event: none this period
```

### 4. Projections (if requested)

- Current daily run rate
- Projected month-end usage at current pace
- Days until monthly quota exhaustion
- Recommendation: "At your current pace, you'll use ~420 of 500
  monthly queries. You have room for your planned batch."

### 5. Offer follow-ups

- "Want me to set up a daily usage digest?"
- "Want me to alert you when you're at 80% of your monthly quota?"
- "Want me to prioritize your remaining queries — which research
  topics are most urgent?"
