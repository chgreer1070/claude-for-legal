---
name: cocounsel-legal:document-drafting
version: 0.1.0
description: >
  Use this skill when a user wants to draft a legal document using
  CoCounsel's document drafting capabilities — contracts, agreements,
  letters, policies, or other legal instruments. Use when the user says
  "draft a contract", "create an NDA", "write a demand letter", or
  "generate a policy." This capability is planned and will be available
  when the CoCounsel Legal MCP server exposes document drafting tools.
status: stub
allowed-tools:
  - mcp
---

# Document Drafting

> **Status: stub** — This skill is ready for activation when the
> CoCounsel Legal MCP server adds document drafting endpoints.
> The workflow below documents the intended behavior.

Draft legal documents using CoCounsel's AI-assisted drafting, grounded
in Westlaw authority and Practical Law templates.

## Prerequisites

The `cocounsel-legal` MCP server must expose document drafting tools.
These tools are not yet available in the current MCP server version.

## When to Use

- User wants to draft a contract, agreement, or legal instrument
- User needs a first draft of a demand letter, response, or
  correspondence
- User wants to generate a policy, procedure, or compliance document
- User has a template and wants to customize it for their matter

## When Not to Use

- Legal research — use `cocounsel-legal:deep-research`
- Formatting an existing research report — use
  `cocounsel-legal:research-export`
- Drafting argument sections from research — use
  `cocounsel-legal:research-brief`

## Planned Workflow

### 1. Gather drafting inputs

Collect:

| Input | Required |
|---|---|
| Document type (contract, letter, policy, etc.) | Yes |
| Parties / key entities | Yes |
| Jurisdiction | Yes |
| Key terms or requirements | Yes |
| Template preference (Practical Law, custom, or from scratch) | No |
| Tone / formality level | No |

### 2. Select template base

When available:
- Search Practical Law for a matching template
- Apply jurisdiction-specific adjustments
- Incorporate user's key terms and requirements

### 3. Generate draft

Produce a first draft with:
- All substantive provisions
- Jurisdiction-appropriate language
- Bracketed alternatives where multiple positions are common
- Comments explaining key choices and alternatives

### 4. Citation support

Where the document references legal authority:
- Link citations to Westlaw
- Verify citations are current via citation-verification
- Flag any authority with negative treatment

### 5. Offer follow-ups

- "Want me to research the enforceability of [key provision] in
  [jurisdiction]?" (routes to `cocounsel-legal:deep-research`)
- "Want me to verify all citations in this draft?"
  (routes to `cocounsel-legal:citation-verification`)
- "Want me to compare this against your standard playbook?"
  (routes to contract review if commercial-legal is available)
- "Want me to draft a companion document (e.g., side letter,
  amendment, exhibit)?"
