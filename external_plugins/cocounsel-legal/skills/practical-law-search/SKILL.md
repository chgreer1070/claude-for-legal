---
name: cocounsel-legal:practical-law-search
version: 0.1.0
description: >
  Use this skill when a user wants to find Practical Law resources —
  standard documents, practice notes, checklists, toolkits, or
  what's-market analyses — from Thomson Reuters Practical Law. Use when
  the user says "find a template", "what's market for", "Practical Law
  checklist", or "standard clause for". This capability is planned and
  will be available when the CoCounsel Legal MCP server exposes
  Practical Law search tools.
status: stub
allowed-tools:
  - mcp
---

# Practical Law Search

> **Status: stub** — This skill is ready for activation when the
> CoCounsel Legal MCP server adds Practical Law search endpoints.
> The workflow below documents the intended behavior.

Search and retrieve Practical Law resources from Thomson Reuters,
including standard documents, practice notes, checklists, toolkits,
clause banks, and what's-market analyses.

## Prerequisites

The `cocounsel-legal` MCP server must expose Practical Law search tools.
These tools are not yet available in the current MCP server version.

## When to Use

- User wants a template, standard document, or form
- User asks "what's market for [term]"
- User needs a practice note or checklist for a transaction type
- User wants to compare their clause against market standard
- User asks for a toolkit for a specific deal type

## When Not to Use

- Legal research questions — use `cocounsel-legal:deep-research`
- Citation verification — use `cocounsel-legal:citation-verification`
- Questions answerable from case law or statutes rather than practice
  resources

## Planned Workflow

### 1. Understand the request

Determine what type of Practical Law resource the user needs:

| Resource type | Example request |
|---|---|
| Standard document | "Find a template NDA" |
| Practice note | "How do I structure a SaaS agreement?" |
| Checklist | "Closing checklist for an asset purchase" |
| What's market | "What's market for a liability cap in SaaS deals?" |
| Toolkit | "M&A toolkit for a private company acquisition" |
| Clause bank | "Standard force majeure clause" |

### 2. Search Practical Law

When available, call the MCP tool with:
- Topic or practice area
- Resource type filter
- Jurisdiction (if relevant)

### 3. Present results

Return results with:
- Resource title and type
- Practice area and jurisdiction
- Last updated date
- Direct link to the resource on Practical Law
- Brief summary of what the resource covers

### 4. Offer follow-ups

- "Want me to compare this template against your existing agreement?"
  (routes to contract review if commercial-legal is available)
- "Want me to research the legal background for this practice area?"
  (routes to `cocounsel-legal:deep-research`)
- "Want me to adapt this checklist to your specific transaction?"
