---
name: harvey-ai:ask-harvey
version: 0.1.0
description: >
  Use this skill whenever a user requests legal research through Harvey AI, asks a general legal question, wants to query documents in a Harvey Vault project, or needs to search specialized legal knowledge sources.
allowed-tools:
  - mcp
---

# Harvey AI — Legal Q&A, Vault Analysis, and Knowledge Source Research

Harvey AI provides general legal Q&A, Vault document analysis, and specialized research knowledge sources through the Harvey MCP server. Each tool call is stateless — the server does not maintain conversation history between requests.

This skill routes user requests to the appropriate Harvey tool and presents responses faithfully.

## Prerequisites

The `harvey-ai` MCP server must be connected. Verify it is available before starting. If the server is not connected, inform the user and stop.

## Available Tools

| Tool | Description |
|------|-------------|
| `ask_harvey` | Ask a general legal question using Harvey's broad legal knowledge |
| `ask_with_knowledge_source` | Ask a question scoped to a specialized research knowledge source |
| `list_knowledge_sources` | List all available research knowledge sources for the user's account |
| `list_vault_projects` | List all Vault projects accessible to the authenticated user |
| `ask_about_vault` | Ask a question about documents in a specific Vault project |

## When to Use

- General legal questions answerable from Harvey's broad legal knowledge base — e.g., elements of a claim, governing standards, statutory interpretation
- Querying specialized research knowledge sources — e.g., UK tax law, jurisdiction-specific databases
- Analyzing documents stored in Harvey Vault projects — e.g., summarizing clauses, comparing provisions, extracting key terms
- Discovering what knowledge sources or Vault projects are available

## When Not to Use

- If the request falls into one of the categories below, briefly explain that this skill isn't the right fit and point the user to the suggested alternative.
  - **Drafting or editing documents** — Harvey MCP exposes read and research tools, not drafting. Suggest Harvey Assistant or the relevant claude-for-legal plugin skill.
  - **Uploading or managing Vault files** — Use Harvey's web interface or the Harvey Vault API.
  - **Analytics or outcome predictions** — Out of scope for Harvey MCP tools.
  - **Non-legal questions** — Harvey's knowledge is legal-domain-specific.

## Communication Rules

- Never mention tool names, MCP internals, or implementation details to the user. Speak about the research or analysis itself, not the mechanics.
- Present Harvey's responses faithfully. Do not editorialize or add legal conclusions beyond what Harvey returns.
- If a tool returns an error, explain it in plain language and suggest next steps (e.g., check permissions, contact Harvey admin).

## Workflow

### 1. Classify the request

Determine which Harvey tool fits the user's request:

- **General legal question** (no specific source or Vault) → `ask_harvey`
- **Question requiring a specific knowledge source** → first call `list_knowledge_sources` if the user hasn't named one, then `ask_with_knowledge_source`
- **Question about Vault documents** → first call `list_vault_projects` if the user hasn't named a project, then `ask_about_vault`
- **Discovery** ("What sources/projects do I have?") → `list_knowledge_sources` or `list_vault_projects`

### 2. Gather required parameters

- **`ask_harvey`**: requires `question` (string) — the legal question in natural language.
- **`ask_with_knowledge_source`**: requires `question` (string) and `knowledge_source_type` (string). Use `list_knowledge_sources` to get valid types if the user hasn't specified one.
- **`ask_about_vault`**: requires `question` (string) and `vault_project_id` (UUID string). Use `list_vault_projects` to get valid project IDs if the user hasn't specified one.

If the user's request is ambiguous about which knowledge source or Vault project to use, present the available options and ask the user to choose.

### 3. Call the tool

Call the appropriate Harvey MCP tool with the gathered parameters.

### 4. Present the response

#### For `ask_harvey` and `ask_with_knowledge_source`

- Present Harvey's answer faithfully, preserving any citations, source references, or structured content in the response.
- If the response includes citations or source links, keep them intact.

#### For `list_knowledge_sources` and `list_vault_projects`

- Present the results as a clean list so the user can choose which source or project to query.

#### For `ask_about_vault`

- Present Harvey's answer faithfully, preserving source citations and document references.
- If the response references specific documents or passages, keep those references intact for the user to verify.

## Helpful Information

If the system fails or the user has questions about access, share the following:

- Support email: support@harvey.ai
- Subscription required: Harvey account with MCP connector enabled. Direct entitlement or access questions to your Harvey workspace administrator or support@harvey.ai.
- Provider: Harvey AI
- Documentation: https://developers.harvey.ai/guides/harvey_mcp
- Relevant policies:
  - Privacy: https://www.harvey.ai/privacy
  - Terms: https://www.harvey.ai/terms
