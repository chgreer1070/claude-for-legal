---
name: cocounsel-legal:citation-verification
version: 0.1.0
description: >
  Use this skill when a user wants to verify, validate, or check the status of
  legal citations — either from a Deep Research report or from any document
  containing case law, statute, or regulatory citations. Checks whether cited
  authority is still good law, identifies negative treatment, and flags
  citations that could not be resolved.
allowed-tools:
  - mcp
  - Bash
---

# Citation Verification

Validates legal citations by checking each against Westlaw's database for
current status, negative treatment, and resolution accuracy. Works on
citations from a completed Deep Research report or from user-supplied text.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. Verify it is available
before starting verification. If the server is not connected, inform the
user and stop.

## When to Use

- After a Deep Research report is delivered and the user asks to verify
  citations before relying on them in a filing or memo
- When the user pastes a list of citations and asks "are these still good law?"
- When the user asks about the treatment of a specific case
- When preparing a brief or memo and the user wants a cite-check pass

## When Not to Use

- Full-text document retrieval — suggest the traditional search box on Westlaw
- Finding new authority on a topic — use `cocounsel-legal:deep-research`
- Analytics on citation patterns — suggest Litigation Analytics on Westlaw

## Communication Rules

- Never mention tool calls, internal identifiers, or implementation mechanics
- Report results in plain, professional language
- When a citation has negative treatment, clearly state what happened and
  when, without alarming language — the attorney decides significance

## Record Fidelity

Every citation status reported by this skill must come from a Westlaw
query via the CoCounsel Legal MCP server. Never report a citation's
treatment status from model knowledge — model knowledge cannot reflect
real-time KeyCite or Shepard's status.

**Source attribution.** Tag every verification result:
- `[Westlaw verified]` — status confirmed via MCP query
- `[unresolved — verify manually]` — query returned no result or an
  ambiguous match; do not guess the status

**When a citation cannot be resolved.** If the MCP server returns no
match or an ambiguous result:
1. Report the citation as `unresolved` — do NOT infer status
2. Suggest the user check manually on Westlaw
3. Never downgrade a citation from "negative" to "good law" based on
   model knowledge — a stale override is worse than a false alarm

## Verification Workflow

### 1. Gather citations

- If a Deep Research conversation is active (the user says "check those
  citations" or "verify the report"), extract all inline citations from
  the most recent `answer_text`.
- If the user pastes text or uploads a document, extract citations from
  the provided content.
- If the user names specific citations, use those directly.
- Parse each citation into its canonical form (e.g., "123 F.3d 456",
  "Cal. Bus. & Prof. Code § 17200").

### 2. Classify citations

Group extracted citations by type:

| Type | Examples |
|---|---|
| Case law | *Smith v. Jones*, 123 F.3d 456 (9th Cir. 2020) |
| Statute | 42 U.S.C. § 1983; Cal. Civ. Code § 1542 |
| Regulation | 17 C.F.R. § 240.10b-5 |
| Administrative | SEC No-Action Letter, FTC Advisory Opinion |
| Secondary | Restatement (Third) of Torts § 46 |

### 3. Verify each citation

For each citation, call the MCP server to check:
- **Resolution**: Does the citation resolve to a document in Westlaw?
- **Status**: For case law — is it good law, distinguished, questioned,
  or overruled? For statutes — is it current, amended, or repealed?
- **Negative treatment**: Any subsequent history that weakens the authority
  (reversed, vacated, superseded by statute, etc.)

Use `legal_research_start_deep_research` with a targeted verification
query for each batch of citations (group by jurisdiction to stay within
the 3-jurisdiction limit).

### 4. Present results

Output a verification table:

```markdown
## Citation Verification Report

| # | Citation | Type | Status | Treatment | Notes |
|---|---|---|---|---|---|
| 1 | *Smith v. Jones*, 123 F.3d 456 (9th Cir. 2020) | Case law | ✅ Good law | Followed | — |
| 2 | *Doe v. Roe*, 456 F.2d 789 (5th Cir. 1998) | Case law | ⚠️ Caution | Distinguished by 3 courts | Review before citing |
| 3 | *State v. Black*, 789 P.2d 012 (Cal. 2015) | Case law | ❌ Overruled | Overruled by *White v. Green* (2022) | Do not cite as authority |
| 4 | Cal. Bus. & Prof. Code § 17200 | Statute | ✅ Current | — | Amended 2023 — verify current text |
```

Status markers:
- ✅ Good law / Current — safe to cite
- ⚠️ Caution — cite with care, note the treatment
- ❌ Negative — overruled, reversed, repealed, or superseded
- ❓ Unresolved — could not verify against Westlaw

### 5. Summarize

After the table, provide:
- **Total citations checked**: N
- **Good law**: N
- **Caution**: N (list the citations)
- **Negative**: N (list with one-line explanation)
- **Unresolved**: N (list with reason)

### 6. Offer follow-ups

- "Want me to find replacement authority for the flagged citations?"
  (routes to `cocounsel-legal:deep-research`)
- "Want me to pull the full text of any of these from Westlaw?"
- "Want me to check additional citations?"
