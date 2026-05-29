---
name: cocounsel-legal:contract-analysis
version: 0.1.0
description: >
  Use this skill when a user wants to analyze a contract using
  CoCounsel's contract analysis capabilities — clause extraction,
  risk identification, term comparison, or obligation mapping. Use
  when the user says "analyze this contract", "what are the risks in
  this agreement", "extract the key terms", or "compare these
  contracts." This capability is planned and will be available when
  the CoCounsel Legal MCP server exposes contract analysis tools.
status: stub
allowed-tools:
  - mcp
---

# Contract Analysis

> **Status: stub** — This skill is ready for activation when the
> CoCounsel Legal MCP server adds contract analysis endpoints.
> The workflow below documents the intended behavior.

Analyze contracts using CoCounsel's AI-powered contract analysis,
with research backing from Westlaw for enforceability and risk
assessment.

## Prerequisites

The `cocounsel-legal` MCP server must expose contract analysis tools.
These tools are not yet available in the current MCP server version.

## When to Use

- User wants to analyze a contract for risks and issues
- User needs key terms extracted from an agreement
- User wants to compare two contracts or compare a contract against
  a playbook
- User needs an obligation map or deadline extraction
- User wants enforceability analysis backed by current case law

## When Not to Use

- Contract review against a firm's playbook with no Westlaw research
  needed — use the practice-area plugin's contract review skill
  (e.g., `commercial-legal:contract-review`)
- Pure legal research — use `cocounsel-legal:deep-research`
- Drafting a new contract — use `cocounsel-legal:document-drafting`

## Planned Workflow

### 1. Ingest the contract

Accept the contract via:
- File upload (PDF, DOCX, or plain text)
- Pasted text in the conversation
- Reference to a document in a connected DMS

### 2. Extract structure

Identify and extract:
- Parties, effective date, term, governing law
- Key commercial terms (fees, caps, indemnities, IP)
- Obligations and deadlines
- Termination rights and notice requirements
- Unusual or non-standard clauses

### 3. Risk assessment

For each extracted clause:
- Compare against market standard (via Practical Law benchmarks)
- Identify departures from standard positions
- Flag enforceability risks based on jurisdiction
- Research supporting or adverse authority via Deep Research where
  relevant

### 4. Present analysis

Output a structured analysis with:

| Clause | Market position | Contract position | Risk level | Notes |
|---|---|---|---|---|
| Liability cap | 12 months fees | 3 months fees | High | Below market; vendor-favorable |

### 5. Offer follow-ups

- "Want me to research the enforceability of [clause] in
  [jurisdiction]?" (routes to `cocounsel-legal:deep-research`)
- "Want me to draft a redline with recommended changes?"
- "Want me to compare this against another contract?"
- "Want me to extract all obligations into a deadline tracker?"
- "Want me to verify all cited authorities?"
  (routes to `cocounsel-legal:citation-verification`)
