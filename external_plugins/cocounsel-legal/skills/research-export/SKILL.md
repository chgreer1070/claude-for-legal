---
name: cocounsel-legal:research-export
version: 0.1.0
description: >
  Use this skill when a user wants to export a completed Deep Research report
  into a work-product format — research memo, brief section, client email,
  or summary. Use when the user says "turn this into a memo", "draft a brief
  section from this research", "summarize this for the partner", or "email
  this to the client".
allowed-tools:
  - mcp
  - Bash
---

# Research Export

Transforms a completed Deep Research report into a polished work-product
format: research memo, brief section, client-facing email, or executive
summary. Preserves all citations and source attribution from the original
report.

## Prerequisites

The `cocounsel-legal` MCP server must be connected (needed to retrieve
reports). If the source report is already in context, the MCP server is
only needed for citation links.

## When to Use

- User has a completed Deep Research report and wants it reformatted
- User says "turn this into a memo", "draft a brief section", "make this
  client-ready", or "summarize for the partner"
- User wants the research in a specific document format with firm/house
  formatting conventions

## When Not to Use

- Drafting legal documents from scratch — suggest CoCounsel
- Starting new research — use `cocounsel-legal:deep-research`
- The user wants the raw report unchanged — it was already delivered
  verbatim by deep-research

## Communication Rules

- Every exported document carries the disclaimer: "RESEARCH NOTES — NOT
  LEGAL ADVICE. Attorney review required before reliance."
- All citations from the original report are preserved — never drop a cite
- Mark the export as "Draft" until the attorney approves

## Export Formats

### Format 1: Research Memo

Standard internal research memo format.

```markdown
# Research Memo

**To:** [recipient — ask if not provided]
**From:** [attorney name — ask if not provided]
**Date:** [today's date]
**Re:** [topic from the research query]

---

**DRAFT — RESEARCH NOTES — NOT LEGAL ADVICE**

## Issue Presented

[Restate the legal question from the original research query]

## Short Answer

[2–3 sentence summary of the key finding]

## Discussion

[Reorganize the Deep Research report into IRAC-style discussion:
- Issue identification
- Rule statement with citations
- Application / analysis
- Conclusion per sub-issue]

## Authorities Cited

[Collect all citations from the report into a table of authorities,
grouped by type (cases, statutes, regulations, secondary sources)]

---
*Generated from Westlaw Deep Research. All citations link to Westlaw.*
```

### Format 2: Brief Section

A section suitable for inserting into a brief or motion.

```markdown
## [Section heading — inferred from the legal issue]

[Narrative legal argument structure:
- Topic sentence stating the rule
- Supporting authority with parenthetical descriptions
- Application to the legal question
- Transition to next point]

[Footnotes for secondary citations and see-also references]
```

- Uses Bluebook citation format
- Includes parenthetical descriptions for each case cite
- Structures arguments from strongest to weakest authority

### Format 3: Client Email

Plain-language summary suitable for a non-lawyer audience.

```markdown
**Subject:** Research Update — [topic]

[Greeting]

[1–2 paragraph summary of findings in plain English:
- What the law says (without legal jargon where possible)
- What it means for the client's situation
- What the options are]

[If there are risks or cautions, state them clearly]

[Next steps recommendation]

[Sign-off]

---
*This summary is based on legal research and is provided for
informational purposes. It does not constitute legal advice.
Please contact us to discuss how this applies to your specific
situation.*
```

### Format 4: Executive Summary

One-page summary for internal stakeholders.

```markdown
## Executive Summary: [topic]

**Bottom line:** [1 sentence — the key takeaway]

**Key findings:**
- [Finding 1 with cite]
- [Finding 2 with cite]
- [Finding 3 with cite]

**Risk level:** [Low / Medium / High — based on strength of authority
and clarity of the law]

**Recommendation:** [1–2 sentences — what the attorney suggests as
next steps]

**Jurisdictions covered:** [list]

**Full report available:** [reference to the complete Deep Research report]
```

## Export Workflow

### 1. Identify the source report

- If a Deep Research report was delivered in the current conversation,
  use it directly
- If the user references a prior session, retrieve it using
  `legal_research_get_deep_research_report(conversation_id)`
- If the user pastes text, use the pasted content

### 2. Select the format

If the user specifies a format, use it. Otherwise, ask:

> "Which format would you like?
> 1. **Research memo** — internal IRAC-style memo
> 2. **Brief section** — ready to insert into a motion or brief
> 3. **Client email** — plain-language summary for a non-lawyer
> 4. **Executive summary** — one-page overview for stakeholders"

### 3. Gather additional details

Depending on the format, ask for:
- **Memo**: recipient name, attorney name (if not in practice profile)
- **Brief section**: which argument or sub-issue to focus on
- **Client email**: client name, level of detail preferred
- **Executive summary**: audience (board, business team, external counsel)

### 4. Generate the export

Transform the Deep Research report content into the selected format:
- Preserve every citation — do not summarize away the authority
- Maintain the citation links to Westlaw and Practical Law
- Apply the format template above
- Add the appropriate disclaimer

### 5. Offer follow-ups

- "Want me to adjust the tone or level of detail?"
- "Want me to export in a different format?"
- "Want me to verify the citations before you finalize?"
  (routes to `cocounsel-legal:citation-verification`)
