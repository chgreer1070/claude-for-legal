# Deep Research Query Guide

*How to frame queries for the CoCounsel Legal Deep Research API to get the best results.*

## Query structure

Deep Research expects a **natural-language legal question**, not a Boolean search. The API parses your question, identifies the legal issue, and searches across Westlaw's full corpus.

### Good queries

| Query | Why it works |
|---|---|
| "How have California courts treated non-compete agreements for executive employees since 2020?" | Specific jurisdiction, specific legal issue, time scope |
| "What is the standard for piercing the corporate veil in Delaware?" | Jurisdiction + specific doctrine |
| "What defenses are available to a defendant in a trade secret misappropriation claim under the DTSA?" | Statute-specific, issue-focused |
| "How do courts apply the business judgment rule when evaluating board decisions to reject merger offers?" | Doctrine + application context |

### Weak queries (and how to improve them)

| Weak query | Problem | Better version |
|---|---|---|
| "non-compete law" | Too broad, no jurisdiction | "How do Texas courts enforce non-compete agreements for at-will employees?" |
| "What does 28 U.S.C. § 1332 say?" | Full-text retrieval, not research | Use Westlaw's document retrieval instead |
| "Will my client win on summary judgment?" | Outcome prediction | "What is the summary judgment standard for negligence claims in the 7th Circuit?" |
| "employment law California" | Topic + jurisdiction, not a question | "What are the current requirements for expense reimbursement under California Labor Code § 2802?" |
| "Tell me everything about ERISA" | Far too broad | "How do courts determine whether a plan administrator's denial of benefits is arbitrary and capricious under ERISA?" |

## Jurisdiction constraints

- **Maximum 3 jurisdictions per query.** The API enforces this limit.
- Jurisdictions must be U.S. federal or state. Foreign law is not supported.
- Specify jurisdictions precisely: "Federal (9th Circuit)" not "federal."
- If the user needs more than 3 jurisdictions, run multiple queries or suggest AI Jurisdictional Surveys on Westlaw.

## Time scoping

- Include a time range when relevant: "since 2020", "in the last 5 years"
- The API searches current law by default — time scoping narrows results, it doesn't limit the database
- For "current state of the law" questions, no time scope needed

## Multi-part questions

- Deep Research handles complex, multi-part questions well
- If the question has multiple distinct issues, consider splitting into separate queries for clearer results
- Example: "What is the statute of limitations for breach of fiduciary duty in New York, and does the discovery rule apply?" — this works as one query because the issues are related

## Follow-up queries

- Use `legal_research_follow_up` with the same `conversation_id` to ask follow-ups
- Follow-ups have full context from the original research
- Good follow-ups: "How does this analysis change if the employee signed the non-compete in Texas but now works in California?"
- Follow-ups that should be new queries: completely different legal issues

## What Deep Research does NOT do

| Request | Why not | Alternative |
|---|---|---|
| Full text of a specific document | Research, not retrieval | Westlaw document search |
| "What does [treatise] say about X?" | Specific-source retrieval | Westlaw content search |
| Analytics ("how often does Judge X rule for defendants?") | Not an analytics tool | Litigation Analytics on Westlaw |
| Date calculations ("when is the filing deadline?") | Not a calculator | Rules-based calendaring tools |
| Outcome predictions | Not a predictor | Legal analytics + attorney judgment |
| Non-U.S. law | U.S. jurisdictions only | Westlaw International |
| Boolean search syntax | Natural language only | Westlaw advanced search |
