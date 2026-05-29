---
name: cocounsel-legal:research-history
version: 0.1.0
description: >
  Use this skill when a user wants to retrieve, review, or manage past
  Westlaw Deep Research sessions — find a previous report by topic,
  re-retrieve a completed report, or list recent research activity.
  Use when the user says "find my earlier research on…",
  "pull up the non-compete report", or "what research have I run?"
allowed-tools:
  - mcp
  - Bash
---

# Research History

Retrieves and manages past Deep Research sessions. Finds previous reports
by topic, re-retrieves completed research, and provides an overview of
recent research activity.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. Verify it is available
before starting. If the server is not connected, inform the user and stop.

## When to Use

- User asks to retrieve a previously completed research report
- User wants to find research they ran on a specific topic or jurisdiction
- User asks "what research have I done recently?" or similar
- User wants to continue a prior research thread (routes to follow-up)

## When Not to Use

- Starting new research — use `cocounsel-legal:deep-research`
- Verifying citations — use `cocounsel-legal:citation-verification`

## Communication Rules

- Never mention conversation IDs, internal identifiers, or API details
- Refer to research sessions by topic and date in natural language
- If a session cannot be found, say so plainly and offer to start new
  research

## Workflow

### 1. Understand the request

Parse the user's request into one of these intents:

| Intent | Trigger phrases |
|---|---|
| **Retrieve specific report** | "pull up the research on…", "get me that non-compete report" |
| **List recent research** | "what research have I run?", "show my research history" |
| **Resume / follow up** | "continue where we left off on…", "follow up on the antitrust research" |

### 2. List recent sessions

Call `legal_research_check_deep_research_status` with known conversation
IDs from the current session context. If the user has no active sessions
in context, inform them:

> "I can retrieve any research report from this session. For earlier
> sessions, share the topic and approximate date and I'll search for it."

For sessions in context, present a summary table:

```markdown
## Recent Research Sessions

| # | Topic | Jurisdictions | Status | Date |
|---|---|---|---|---|
| 1 | Non-compete enforceability for executives | CA, TX | Complete | 2026-05-28 |
| 2 | Trade secret misappropriation defenses | NY | Complete | 2026-05-27 |
| 3 | TCPA class action standing | Federal | In progress | 2026-05-29 |
```

### 3. Retrieve a report

Once the user identifies which session they want:
- If the session is complete, call
  `legal_research_get_deep_research_report(conversation_id)` and present
  the `answer_text` verbatim (same rendering rules as deep-research).
- If the session is still in progress, poll for completion using the
  deep-research polling workflow.
- If the session failed, report the failure in plain language and offer
  to re-run the research.

### 4. Resume with follow-up

If the user wants to continue a completed session:
- Confirm the session topic and jurisdictions
- Route to `follow_up_deep_research(conversation_id, query)` with the
  user's new question
- Follow the deep-research polling and report workflow

### 5. Offer follow-ups

- "Want me to verify the citations in this report?"
  (routes to `cocounsel-legal:citation-verification`)
- "Want me to export this as a memo or brief section?"
  (routes to `cocounsel-legal:research-export`)
- "Want me to run a follow-up question on this research?"
  (routes to `follow_up_deep_research`)
