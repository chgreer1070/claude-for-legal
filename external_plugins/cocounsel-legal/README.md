# CoCounsel Legal

CoCounsel Legal brings Westlaw Deep Research into Claude for CoCounsel Legal subscribers. Run jurisdiction-specific legal research across U.S. federal and state law and receive fully cited reports with Westlaw and Practical Law source links. Deep Research reports cite case law, statutes, regulations, administrative materials, Practical Law, secondary sources, and current awareness content. Ask follow-up questions in the same conversation. The connector launches with Westlaw Deep Research and will expand to additional CoCounsel Legal capabilities over time.

- Use CoCounsel Legal to run Westlaw Deep Research with fully cited reports including linked citations to Westlaw and Practical Law sources.
- Ask about legal research in up to three U.S. jurisdictions in a single research run.
- Return to a completed CoCounsel Legal research conversation and retrieve the report later.
- Ask follow-up questions in the same conversation without restarting research.

## Setup

Run `/cocounsel-legal:cold-start-interview` on first use. It configures your research defaults (jurisdictions, citation format, subscription tier) so every skill reads your preferences automatically. Takes ~5 minutes. See `CLAUDE.md` for the full research profile template.

## Skills

| Skill | Command | What it does |
|---|---|---|
| **Cold-Start Interview** | `/cocounsel-legal:cold-start-interview` | Setup interview — configures research defaults, jurisdiction preferences, subscription tier, citation format, and cross-plugin routing. |
| **Deep Research** | `/cocounsel-legal:deep-research` | Runs the full Westlaw Deep Research cycle: start, poll, report. Returns a fully cited research report. |
| **Citation Verification** | `/cocounsel-legal:citation-verification` | Validates citations from a Deep Research report or user-supplied text. Checks good-law status, negative treatment, and resolution accuracy. |
| **Jurisdiction Comparison** | `/cocounsel-legal:jurisdiction-comparison` | Side-by-side comparison of how 2–3 U.S. jurisdictions treat the same legal issue. Produces a structured comparison table with citations. |
| **Research Export** | `/cocounsel-legal:research-export` | Transforms a completed research report into a work-product format: research memo, brief section, client email, or executive summary. |
| **Research History** | `/cocounsel-legal:research-history` | Retrieves and manages past Deep Research sessions. Find a previous report by topic, re-retrieve completed research, or list recent activity. |
| **Research Brief** | `/cocounsel-legal:research-brief` | Takes a Deep Research report + case theory and drafts a structured legal argument section with authority marshaling and counter-argument anticipation. |
| **Quota Tracker** | `/cocounsel-legal:quota-tracker` | Tracks API usage against subscription limits. Shows remaining daily/monthly quota, concurrent sessions, and usage projections. |
| **Case Law Monitor** | `/cocounsel-legal:case-law-monitor` | Sets up proactive monitoring of a legal topic for new case law developments. Produces periodic digests comparing new decisions against a baseline landscape. |

### Planned capabilities (stubs)

These skills are defined and ready for activation when the CoCounsel Legal MCP server exposes the corresponding endpoints:

| Skill | Command | Status |
|---|---|---|
| **Practical Law Search** | `/cocounsel-legal:practical-law-search` | Stub — awaiting MCP endpoint |
| **Document Drafting** | `/cocounsel-legal:document-drafting` | Stub — awaiting MCP endpoint |
| **Contract Analysis** | `/cocounsel-legal:contract-analysis` | Stub — awaiting MCP endpoint |

## Agents

### Inline agents

| Agent | Location | What it does |
|---|---|---|
| **Research Monitor** | `agents/research-monitor.md` | Scheduled agent that runs periodic Deep Research checks on monitored topics, compares against baselines, and produces digests of new case law developments. |

### Managed agent cookbooks

| Agent | Location | What it does |
|---|---|---|
| **Authority Tracker** | `managed-agent-cookbooks/authority-tracker/` | Scheduled agent that monitors cited authorities for negative treatment changes (like KeyCite alerts) and posts Slack alerts when a relied-on case is distinguished, overruled, or otherwise weakened. |

## Cross-plugin integrations

CoCounsel Legal is registered as an MCP connector in these practice-area plugins:

| Plugin | Use case |
|---|---|
| `litigation-legal` | Case research, claim charts, motion prep, authority verification |
| `commercial-legal` | Contract clause enforceability, governing law research |
| `regulatory-legal` | Regulatory interpretation, enforcement action research |
| `ip-legal` | Patent/trademark case law, IP litigation research |
| `employment-legal` | Employment law research, wage/hour, classification |
| `corporate-legal` | M&A diligence research, governance questions |
| `privacy-legal` | Privacy regulation research, enforcement actions |

## Example use cases

1. Research how California courts have treated non-compete agreements for executive employees since 2020.
2. I asked you to research California non-competes earlier. Can you now retrieve the full report?
3. Follow up on that research: how does Texas law differ on executive non-competes for the same period?
4. Verify all citations in that report before I include them in the brief.
5. Compare California, Texas, and New York on trade secret misappropriation standards.
6. Turn that research into a memo for the partner.
7. Export an executive summary of the antitrust research for the business team.
8. Draft the summary judgment argument section from that research — my theory is that the non-compete is overbroad.
9. Check my API usage — how many research queries do I have left this month?
10. Find me a Practical Law template for a SaaS agreement. *(planned)*
11. Monitor non-compete enforceability in California for new case law — alert me when there's a new ruling.
12. Set up my research profile — I mostly work in California and Federal 9th Circuit.

## When to Use

Any questions answerable from caselaw, statutes, regulations, administrative materials, secondary sources, Practical Law documents and current awareness, including JD Supra. Examples include:

- How courts have ruled on an issue or what authority supports or challenges a position
- The elements or defenses of a claim, or the governing standard for an issue in a particular jurisdiction
- How a statute, regulation, or doctrine is being interpreted and applied
- The arguments on both sides of an unsettled question

## When Not to Use

- Retrieving the full text of a specific document
- Summarizing what a specific statute, regulation, or treatise says on its own (e.g., "what does the California Evidence Code say about hearsay?" or "what does Wright & Miller say about Rule 11?")
- Analytics requests ("How often has Justice Scalia ruled in favor of...?")
- Calculations ("What is the last possible filing date if...?")
- Outcome predictions ("How likely is plaintiff to prevail on summary judgment?")
- Identifying causes of action a client could bring (the skill researches what the law says, not whether a given set of facts states a claim)
- Applying law to a specific fact pattern or scenario (the skill researches legal questions in the abstract, not how the law would resolve your facts)
- Drafting legal documents, forms, or templates *(planned — see document-drafting stub)*
- Information about specific judges, attorneys, or parties
- Foreign or non-U.S. law
- Commands to execute tasks ("Send me an email about X case")
- General legal definitions that don't require current authority
- Comparisons across more than three jurisdictions
- Boolean search queries (the tool expects natural language)

## Database

The `db/` directory contains a reference PostgreSQL schema and indexes optimized for the plugin's data access patterns, plus a versioned migration system under `db/migrations/`. See [db/README.md](db/README.md) and [db/migrations/README.md](db/migrations/README.md).

### Links

- **Documentation:** https://legal-mcp.thomsonreuters.com/docs/connector-guide
- **Support:** cocounselsupport@tr.com
