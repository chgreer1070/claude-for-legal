---
name: midpage-legal:research-case-law
version: 0.1.0
description: >
  Use this skill whenever a user needs to research US case law, find specific court opinions, locate quotable passages within an opinion, or analyze the content of a judicial decision.
allowed-tools:
  - mcp
---

# Midpage Legal Research — Case Law Search and Opinion Analysis

Midpage provides access to a comprehensive database of US federal and state court opinions through a remote MCP server. Each tool call is stateless — the server does not maintain conversation history between requests.

This skill routes user requests to the appropriate Midpage tool and presents responses faithfully with all hyperlinks and citations preserved.

## Prerequisites

The `midpage-legal` MCP server must be connected. Verify it is available before starting. If the server is not connected, inform the user and stop.

## Available Tools

| Tool | Description |
|------|-------------|
| `search` | Search US case law (federal and state) by keyword, legal issue, or natural language query |
| `findInOpinion` | Find quotable passages within a specific court opinion |
| `analyzeOpinion` | Ask analytical questions about the content of a specific opinion |

## When to Use

- Searching for case law on a legal issue, doctrine, or factual scenario
- Finding specific court opinions by case name, citation, or legal topic
- Locating quotable passages or key holdings within a known opinion
- Analyzing what a court said about a specific issue in a given case
- Verifying whether a cited case actually supports a stated proposition
- Building a research memo with primary source citations

## When Not to Use

- **Statutory or regulatory research** — Midpage focuses on case law (court opinions). For statutes, suggest CourtListener, Harvey AI, or a statutory research tool.
- **Citator analysis** (Is this case still good law? Has it been overruled?) — Midpage search does not perform Shepard's/KeyCite-style validation. Note this limitation when presenting results.
- **Non-US jurisdictions** — Midpage's coverage is US federal and state courts. For international case law, suggest Harvey AI or another appropriate source.
- **Drafting documents** — This is a research tool, not a drafting tool.

## Communication Rules

- Never mention tool names, API versions, MCP internals, or implementation details to the user.
- Present all results with hyperlinks and full citations intact. Midpage responses include clickable links to source opinions — always preserve these.
- If a tool returns an error, explain it plainly and suggest a retry or alternative approach.

## Workflow

### 1. Classify the request

Determine which Midpage tool fits:

- **General case law search** (find cases on a topic, issue, or fact pattern) → `search`
- **Find a passage in a specific opinion** (the user knows the case and wants a quote) → `findInOpinion`
- **Analyze an opinion** (the user wants to understand what a court held or said about an issue) → `analyzeOpinion`

### 2. Gather required parameters

- **`search`**: requires `query` (string) — a natural language description of the legal issue, doctrine, or fact pattern. May optionally include jurisdiction filters.
- **`findInOpinion`**: requires `opinion_id` or citation identifier, plus `query` (string) describing what passage to find. If the user gives a case name without an ID, first use `search` to locate the opinion, then use `findInOpinion`.
- **`analyzeOpinion`**: requires `opinion_id` or citation identifier, plus `question` (string) about the opinion's content. If the user gives a case name without an ID, first use `search` to locate it.

If the user's request is ambiguous about which case they mean, present search results and ask them to confirm before analyzing.

### 3. Call the tool

Call the appropriate Midpage MCP tool with the gathered parameters.

### 4. Present the response

#### For `search`

- Present results as a numbered list with full case citations, court, year, and a brief description of relevance.
- Preserve all hyperlinks to source opinions.
- If the result set is large, summarize the most relevant cases first and offer to show more.

#### For `findInOpinion`

- Present the quotable passage with exact attribution (case name, page/paragraph reference).
- Preserve the hyperlink to the source location within the opinion.
- Note if the passage is from a majority, concurrence, or dissent.

#### For `analyzeOpinion`

- Present Midpage's analysis faithfully, preserving any internal citations or cross-references.
- If the analysis references other cases, preserve those citations and links.

## Helpful Information

If the system fails or the user has questions about access:

- Support: support@midpage.ai
- Documentation: https://midpage-docs.apidocumentation.com
- Free trial: https://app.midpage.ai
