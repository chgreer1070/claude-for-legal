---
name: cocounsel-legal:jurisdiction-comparison
version: 0.1.0
description: >
  Use this skill when a user wants to compare how different U.S. jurisdictions
  treat a legal issue — side-by-side analysis across 2–3 states or federal
  circuits. Use when the user says "compare California and Texas on…",
  "how does NY differ from federal on…", or "jurisdiction comparison".
allowed-tools:
  - mcp
  - Bash
---

# Jurisdiction Comparison

Runs Deep Research across 2–3 jurisdictions on the same legal question
and produces a structured side-by-side comparison table with citations.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. Verify it is available
before starting. If the server is not connected, inform the user and stop.

## When to Use

- User asks to compare the same legal issue across multiple U.S. jurisdictions
- User says "how does [State A] differ from [State B] on…"
- User needs a jurisdiction survey for up to 3 jurisdictions
- User asks "which state is more favorable for…"

## When Not to Use

- Comparisons across more than 3 jurisdictions — suggest AI Jurisdictional
  Surveys on Westlaw
- Foreign or non-U.S. law — suggest the country-specific version of Westlaw
- Single-jurisdiction research — use `cocounsel-legal:deep-research`

## Communication Rules

- Never mention tool calls, conversation IDs, or implementation details
- Present comparisons neutrally — the attorney draws legal conclusions
- Clearly state which jurisdictions were compared and what question was asked
- Flag areas where the law is unsettled or where jurisdictions have
  conflicting authority

## Comparison Workflow

### 1. Frame the comparison

- Extract the legal question from the user's request
- Identify the jurisdictions to compare (2–3; reject if more than 3)
- If jurisdictions are not specified, ask: "Which jurisdictions should I
  compare? I can cover up to three."
- Confirm the question and jurisdictions with the user before proceeding

### 2. Run research

Call `legal_research_start_deep_research(query, jurisdictions)` with all
specified jurisdictions in a single research run (the API supports up to 3).

- Follow the standard deep-research polling workflow (poll → sleep → poll
  until `is_terminal` is true)
- On completion, retrieve the report via
  `legal_research_get_deep_research_report(conversation_id)`

### 3. Extract jurisdiction-specific findings

Parse the completed report and organize findings by jurisdiction. For each
jurisdiction, identify:
- **Governing rule / standard** — the key statute, regulation, or common-law
  test
- **Leading authority** — the most-cited or most-recent controlling case
- **Key elements / factors** — what the jurisdiction requires or weighs
- **Trends / open questions** — recent developments, circuit splits, pending
  legislation

### 4. Present the comparison

Output a structured comparison table:

```markdown
## Jurisdiction Comparison: [Legal Issue]

| Dimension | [Jurisdiction 1] | [Jurisdiction 2] | [Jurisdiction 3] |
|---|---|---|---|
| **Governing standard** | [rule / test] | [rule / test] | [rule / test] |
| **Key statute** | [cite] | [cite] | [cite] |
| **Leading case** | [cite] | [cite] | [cite] |
| **Elements / factors** | [list] | [list] | [list] |
| **Burden** | [who bears it] | [who bears it] | [who bears it] |
| **Damages / remedies** | [available remedies] | [available remedies] | [available remedies] |
| **Trend** | [direction] | [direction] | [direction] |
| **Open questions** | [if any] | [if any] | [if any] |
```

Adjust rows based on relevance to the legal question. Not all rows apply
to every topic.

### 5. Key differences summary

After the table, provide a narrative summary (3–5 sentences) highlighting
the most significant differences between the jurisdictions. Focus on
differences that would affect legal strategy or risk assessment.

### 6. Offer follow-ups

- "Want me to drill deeper into any of these jurisdictions?"
  (routes to `cocounsel-legal:deep-research` for a single jurisdiction)
- "Want me to verify the citations in this comparison?"
  (routes to `cocounsel-legal:citation-verification`)
- "Want me to export this as a memo?"
  (routes to `cocounsel-legal:research-export`)
