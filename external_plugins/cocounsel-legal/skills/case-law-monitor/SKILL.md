---
name: cocounsel-legal:case-law-monitor
version: 0.2.0
description: >
  Use this skill when a user wants to set up ongoing monitoring of a
  legal topic, statute, or issue area for new case law developments.
  Unlike citation-verification (which checks existing citations) or
  authority-tracker (which monitors specific relied-on cases), this
  skill watches for NEW decisions on a topic. Use when the user says
  "alert me when there's a new ruling on…", "monitor this issue",
  "watch for new case law on…", or "set up a legal alert."
allowed-tools:
  - mcp
  - Bash
---

# Case Law Monitor

Sets up and runs proactive monitoring for new case law developments on
a topic, in specified jurisdictions. Produces periodic digest reports
summarizing new decisions, their holdings, and their practical impact.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. Verify before
starting. If not connected, inform the user and stop.

## When to Use

- User wants to track an evolving area of law for new decisions
- User says "alert me when there's a new ruling on…"
- User wants a periodic digest of new case law in a practice area
- User is monitoring a statute for new interpretation or application
- User wants to know when a circuit split develops or resolves

## When Not to Use

- Checking the current status of specific citations — use
  `cocounsel-legal:citation-verification`
- Monitoring specific relied-on cases for negative treatment — use
  the authority-tracker managed agent
- One-time research — use `cocounsel-legal:deep-research`
- Comparing how jurisdictions currently treat an issue — use
  `cocounsel-legal:jurisdiction-comparison`

## Communication Rules

- Never mention tool calls, conversation IDs, or implementation details
- Present new developments in plain, professional language
- When reporting a new decision, state the holding, the court, and
  the practical significance — the attorney decides what to do with it
- Flag decisions that may conflict with the user's established position
  using `[review]`

## Monitoring Workflow

### 1. Define the watch topic

Collect:

| Input | Required | Example |
|---|---|---|
| **Topic or legal issue** | Yes | "Non-compete enforceability for remote workers" |
| **Jurisdictions** | Yes (up to 3) | "California, Delaware, Federal" |
| **Scope refinement** | No | "Only appellate decisions", "Only published opinions" |
| **Relevance filter** | No | "Focus on technology sector employees" |
| **Baseline date** | No | "Since January 2025" (default: last 30 days) |

If the user's topic is too broad (e.g., "employment law"), suggest
narrowing: "That's a broad topic. Want to focus on a specific issue
like non-compete enforceability, trade secret misappropriation, or
wage-and-hour classification?"

### 2. Run baseline research

Run `legal_research_start_deep_research(query, jurisdictions)` with a
query framed for recent developments:

- Query pattern: "Recent [court level] decisions on [topic] in
  [jurisdictions] since [baseline date], focusing on new holdings,
  shifts in interpretation, or emerging trends"
- Follow the standard deep-research polling workflow

This establishes the current state of the law as the baseline against
which new developments are measured.

### 3. Extract the current landscape

From the baseline research report, extract:

- **Controlling authority** — the current leading cases by jurisdiction
- **Current rule / standard** — how the issue is currently resolved
- **Open questions** — areas where the law is unsettled, circuit splits,
  pending cases
- **Trend direction** — which way the law appears to be moving

Present as a landscape summary:

```markdown
## Case Law Landscape: [Topic]

**As of:** [date]
**Jurisdictions:** [list]

### Current state of the law

[2-3 paragraph summary of where things stand]

### Controlling authority by jurisdiction

| Jurisdiction | Leading case | Holding | Date |
|---|---|---|---|
| [Jur. 1] | [cite] | [one-line holding] | [date] |

### Open questions

- [Question 1 — e.g., "No appellate decision yet on remote-worker
  non-competes in Delaware"]
- [Question 2]

### Trend

[Direction the law is moving, if discernible]
```

### 4. Configure the monitor

Confirm the monitoring parameters with the user:

> "Here's what I'll monitor:
> - **Topic:** [topic]
> - **Jurisdictions:** [list]
> - **Scope:** [any filters]
> - **Check frequency:** [suggest based on topic volatility — weekly
>   for active areas, monthly for stable ones]
>
> I'll run a Deep Research query on this topic at each check and
> compare against the baseline to identify new developments. Want me
> to set this up?"

Save the monitor configuration to the authority watch list in the
research profile.

### 5. Run a check (on-demand or scheduled)

When running a monitoring check (manually or via scheduled trigger):

1. Run Deep Research on the watch topic with the same jurisdictions
2. Compare the results against the baseline landscape
3. Identify new decisions, changed holdings, or new developments
4. Classify each development:

| Classification | Meaning | Action |
|---|---|---|
| **New controlling authority** | A new binding decision | `[review]` — may change legal position |
| **Trend confirmation** | New decision follows existing trend | Note, no flag |
| **Trend reversal** | Decision goes against the trend | `[review]` — flag for attorney |
| **Circuit split** | Jurisdictions now disagree | `[review]` — note the split |
| **Statutory change** | Legislature acted on the topic | `[review]` — may supersede case law |

### 6. Present the digest

```markdown
## Case Law Monitor Digest: [Topic]

**Period:** [last check date] to [this check date]
**Jurisdictions:** [list]

### New developments

| # | Decision | Court | Date | Classification | Impact |
|---|---|---|---|---|---|
| 1 | [cite] | [court] | [date] | [type] | [one-line] |

### Details

#### 1. [Case name]

**Holding:** [one paragraph]

**Significance:** [why this matters for the monitored topic]

**Impact on prior position:** [how this changes or confirms the
baseline landscape] `[review]`

### Updated landscape

[If the landscape has materially changed, provide an updated summary.
If not: "No material change to the baseline landscape."]
```

### 7. Offer follow-ups

- "Want me to run a full Deep Research query on any of these new
  decisions?" (routes to `cocounsel-legal:deep-research`)
- "Want me to check if any of these new decisions affect your cited
  authorities?" (routes to `cocounsel-legal:citation-verification`)
- "Want me to draft an updated argument section incorporating the new
  authority?" (routes to `cocounsel-legal:research-brief`)
- "Want me to adjust the monitoring scope or jurisdictions?"
- "Want me to send this digest to a Slack channel?" (if Slack is
  configured)
