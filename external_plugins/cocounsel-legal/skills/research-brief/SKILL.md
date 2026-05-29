---
name: cocounsel-legal:research-brief
version: 0.1.0
description: >
  Use this skill when a user has a completed Deep Research report and a case
  theory or motion type and wants to draft an argumentative brief section —
  not just a format export, but a structured legal argument with authority
  marshaling, counter-argument anticipation, and standard-of-review framing.
  Use when the user says "draft the argument section", "write the summary
  judgment brief from this research", "build the motion to dismiss argument",
  or "I need a brief section, not just a memo."
allowed-tools:
  - mcp
  - Bash
---

# Research Brief Drafter

Takes a completed Deep Research report and a case theory or motion type
and drafts a structured legal argument section suitable for insertion into
a brief. Goes beyond format conversion (research-export) by marshaling
authority, anticipating counter-arguments, and framing the standard of
review.

## Prerequisites

The `cocounsel-legal` MCP server must be connected. If the source report
is already in context, the MCP server is only needed for follow-up
research on gaps.

## When to Use

- User has a Deep Research report and wants an argument drafted, not
  just reformatted
- User says "draft the argument section", "write the brief from this",
  "build the motion to dismiss argument"
- User has a case theory and wants authority marshaled into argument form
- User needs to anticipate and address counter-arguments

## When Not to Use

- Simple format conversion — use `cocounsel-legal:research-export`
- Starting fresh research — use `cocounsel-legal:deep-research`
- Cite-checking without argument — use `cocounsel-legal:citation-verification`
- Full brief drafting from scratch — suggest CoCounsel

## Communication Rules

- The output is a draft for attorney review — always say so
- Every legal proposition must have a citation
- Present counter-arguments fairly; do not strawman
- Note where authority is thin and additional research may be needed
- Flag circuit splits and unsettled law clearly

## Brief Drafting Workflow

### 1. Gather inputs

Collect three things:

| Input | Source | Required |
|---|---|---|
| **Research report** | Active conversation, conversation_id, or pasted text | Yes |
| **Case theory** | User states it, or extracted from a matter.md | Yes |
| **Motion type / procedural posture** | User states it (e.g., MSJ, MTD, opposition) | Yes |

If any input is missing, ask. Example prompt:

> "I have the research. To draft the argument, I need:
> 1. Your case theory — what's the core argument?
> 2. The motion type — summary judgment, motion to dismiss, opposition,
>    or something else?"

### 2. Determine the standard of review

Based on the motion type, identify and state the applicable standard:

| Motion | Standard |
|---|---|
| Motion to dismiss (12(b)(6)) | Accept all well-pleaded facts as true; plausible on its face |
| Summary judgment | No genuine dispute of material fact; movant entitled to judgment as a matter of law |
| Preliminary injunction | Likelihood of success, irreparable harm, balance of equities, public interest |
| Motion in limine | Relevance, probative value vs. prejudice (FRE 401–403) |
| Opposition | Mirror the movant's standard; show genuine disputes or legal error |

If the jurisdiction has a variation (e.g., state summary judgment standard
differs from federal), note it.

### 3. Marshal authority

From the Deep Research report, organize citations into:

- **Controlling authority** — binding precedent in the jurisdiction
  (Supreme Court, relevant circuit, highest state court)
- **Persuasive authority** — other circuits, state appellate courts,
  treatises, law review articles
- **Adverse authority** — cases or statutes the opposing side will cite;
  how to distinguish or limit them

For each authority, draft a parenthetical description:
```
*Smith v. Jones*, 123 F.3d 456, 460 (9th Cir. 2020) (holding that
non-compete agreements for executive employees are enforceable where
the restriction is reasonable in scope and duration).
```

### 4. Draft the argument

Structure the argument section following this template:

```markdown
## [Argument heading — framed as a conclusion]

### A. Standard of Review

[State the standard; cite the leading case]

### B. [First major argument point]

[Topic sentence stating the legal rule]

[Supporting authority with parentheticals, strongest first]

[Application to the case theory — how the facts satisfy the rule]

[Transition to next point]

### C. [Second major argument point]

[Same structure]

### D. [Anticipate and address counter-arguments]

[State the likely counter-argument fairly]

[Distinguish adverse authority or show why it doesn't apply]

[Explain why the court should adopt your position]

### E. Conclusion

[One paragraph summarizing why the motion should be granted / denied]
```

Adapt the number of sections to the complexity of the issue. Simple
motions may need only A–C; complex motions may need A–F.

### 5. Citation format

- Use Bluebook citation format throughout
- Include pin cites to specific pages where the court stated the rule
- Use parenthetical descriptions for every case citation
- Signal citations appropriately: *see*, *see also*, *cf.*, *but see*,
  *contra*
- Include subsequent history where relevant (*aff'd*, *rev'd*, *cert.
  denied*)

### 6. Gap analysis

After drafting, identify:
- Areas where authority is thin (note: "Additional research recommended
  on [topic]")
- Adverse authority that has not been fully addressed
- Jurisdictional questions (e.g., issue of first impression in this
  circuit)

Offer to run targeted Deep Research to fill gaps:
> "The argument on [point] could be strengthened with additional
> authority. Want me to run a focused Deep Research query on [specific
> question]?"

### 7. Offer follow-ups

- "Want me to draft the statement of facts to go with this argument?"
- "Want me to research the opposing side's best arguments so you can
  preempt them?"
- "Want me to verify all citations before you file?"
  (routes to `cocounsel-legal:citation-verification`)
- "Want me to draft a companion section on a related issue?"
