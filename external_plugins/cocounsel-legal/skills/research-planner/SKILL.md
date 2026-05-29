---
name: cocounsel-legal:research-planner
version: 0.3.0
description: >
  Use this skill when a user has a legal question but hasn't framed it
  for Deep Research yet. Helps identify the right jurisdictions, narrow
  the issue, suggest query phrasing, and estimate quota cost before
  committing API calls. Use when the user says "I need to research…",
  "help me frame this question", "what's the best way to search for…",
  or when the question is too broad, too narrow, or ambiguous for a
  single Deep Research run.
allowed-tools:
  - mcp
  - Bash
---

# Research Planner

Helps the user frame a legal question before running Deep Research.
Identifies jurisdictions, narrows the issue, suggests query phrasing,
and estimates how many API calls the research will require. Upstream of
deep-research — use this when the question needs shaping, not when the
user already knows exactly what to ask.

## Prerequisites

No MCP server call is required for planning. The skill reads the
research profile for default jurisdictions and quota status but does
not consume API calls.

## When to Use

- User has a vague or broad legal question ("I need to research
  non-competes" without jurisdiction or scope)
- User asks "help me frame this" or "what should I search for?"
- Question spans more than 3 jurisdictions (needs splitting)
- User is unsure which jurisdictions are relevant
- User wants to estimate API cost before running research
- Multiple related legal issues that might need separate queries

## When Not to Use

- User has a well-framed question ready to go — route directly to
  `cocounsel-legal:deep-research`
- User wants to check existing citations — use
  `cocounsel-legal:citation-verification`
- User is asking about the plugin's capabilities, not framing research

## Communication Rules

- Never mention tool calls or implementation details
- Present options clearly — the user chooses the research path
- Be honest about what Deep Research can and cannot answer (see
  `references/deep-research-query-guide.md`)
- When suggesting jurisdictions, explain why each matters for the issue
- Never run a Deep Research query during planning — that's the user's
  decision after seeing the plan

## Planning Workflow

### 1. Understand the question

Ask clarifying questions to identify:

| Element | What to determine | Example |
|---|---|---|
| **Legal issue** | The specific legal question | "enforceability of non-competes for remote workers" |
| **Context** | Why the user needs this research | "drafting a motion to dismiss", "advising a client", "due diligence" |
| **Jurisdictions** | Which jurisdictions matter | "employee is in CA, company is in TX, contract says NY law" |
| **Time scope** | Relevant time period | "recent developments", "since 2020", "current state" |
| **Depth** | How deep to go | "quick overview" vs "comprehensive analysis for a brief" |

If the research profile has default jurisdictions, suggest them:
"Your defaults are [jurisdictions]. Are those right for this question,
or should we target different ones?"

### 2. Assess the question

Classify the question against Deep Research's capabilities:

| Assessment | Action |
|---|---|
| **Ready as-is** | Tell the user their question is well-framed and offer to run it |
| **Too broad** | Suggest 2-3 narrower sub-questions |
| **Too narrow** | Suggest broadening (e.g., add related doctrines, expand time scope) |
| **Multi-jurisdiction (>3)** | Split into groups of 3 and estimate the number of queries |
| **Multi-issue** | Split into separate queries, one per issue |
| **Not a research question** | Explain what Deep Research doesn't do and suggest alternatives |

### 3. Propose a research plan

Present the plan as a numbered list of queries:

```markdown
## Research Plan

**Goal:** [one-line summary of what the user wants to learn]

### Query 1: [short description]
- **Question:** "[the natural-language query]"
- **Jurisdictions:** [list, max 3]
- **Expected output:** [what kind of answer to expect]

### Query 2: [if needed]
- **Question:** "[the natural-language query]"
- **Jurisdictions:** [list, max 3]
- **Expected output:** [what kind of answer to expect]

**Estimated API calls:** [N] (of [daily remaining] daily / [monthly remaining] monthly)
**Estimated time:** ~[N] minutes per query ([total] total)
```

If the user's quota is low, note it: "You have [N] queries left this
month. This plan uses [M]. Want to prioritize or combine any?"

### 4. Refine with the user

Ask: "Does this plan look right? I can adjust jurisdictions, scope,
or phrasing before we start."

Common refinements:
- Combining queries that can be answered together
- Reordering by priority (most important query first)
- Adding a follow-up strategy: "If Query 1 shows X, we'll also want
  to ask Y"

### 5. Hand off to deep-research

Once the user approves the plan, offer to execute:

> "Ready to run. Want me to start with Query 1?"

Route to `cocounsel-legal:deep-research` with the approved query and
jurisdictions. If the plan has multiple queries, run them in the order
the user approved.

### 6. Offer follow-ups

After planning:
- "Want me to run this research now?" (routes to
  `cocounsel-legal:deep-research`)
- "Want me to refine the jurisdictions?" (iterate on the plan)
- "Want me to check your remaining quota first?" (routes to
  `cocounsel-legal:quota-tracker`)
- "Want me to save this plan for later?"
