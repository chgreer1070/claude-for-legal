# Westlaw Research Currency Watch

**Last verified: 2026-05-29.**

> **Staleness check.** If the last-verified date above is more than 90 days old, treat this file as stale and verify each entry before relying on it. When a skill reads this file, check the last-verified date first. If stale, say: "The currency watch was last verified [date]. I'm using it as a checklist of areas to search, not as a source of current status." When you update any entry, also update the last-verified date at the top.

Legal research depends on currency. These are areas where the law is actively shifting and model knowledge is most likely stale:

## CoCounsel Legal API changes

- **MCP server version:** Verify the current API capabilities match what the skills expect. New endpoints may have shipped since the stubs were written.
- **Jurisdiction coverage:** The API currently supports U.S. federal and state law only. Check whether international coverage has been added.
- **Rate limits:** Subscription tiers and quotas may change. Verify against the current CoCounsel Legal documentation.

## Areas of active legal change (U.S.)

### Non-compete agreements
- **FTC Non-Compete Rule:** Status in flux. Verify whether the FTC's proposed nationwide ban on non-competes is in effect, enjoined, or vacated. Check at [FTC non-compete page](https://www.ftc.gov/legal-library/browse/rules/noncompete-rule).
- **State-level changes:** California (always void), Colorado (income threshold), Minnesota (banned 2023), multiple other states have enacted or amended non-compete restrictions. Verify current state of each relevant jurisdiction.

### AI and technology law
- **AI regulation:** EU AI Act implementation timeline, state-level AI laws (CO, IL, others). Verify current effective dates and scope.
- **Copyright and AI:** Evolving case law on AI-generated content, training data, and fair use. Check for new decisions.
- **Section 230:** Active litigation and proposed amendments. Verify current scope.

### Employment law
- **Worker classification:** DOL independent contractor rule, state ABC tests. Verify which standard applies in the relevant jurisdiction.
- **Pay transparency:** State and local laws expanding rapidly. Verify current requirements.
- **Arbitration agreements:** Supreme Court and circuit court developments on enforceability.

### Privacy (see also privacy-legal/references/currency-watch.md)
- **State privacy laws:** New comprehensive privacy laws take effect each year. Verify the IAPP state law tracker.
- **COPPA 2025 amendments:** Compliance deadline April 22, 2026.
- **EU-US DPF:** Subject to Schrems III litigation.

### Corporate / M&A
- **Beneficial ownership reporting:** Corporate Transparency Act and FinCEN BOI reporting. Verify current status and any injunctions.
- **Delaware corporate law:** DGCL amendments and Chancery Court developments.

## How skills should use this file

When a Deep Research query touches one of these areas:
1. Note the currency risk in the reviewer note: "This area is in active flux — see `references/currency-watch.md`."
2. If a follow-up query would add value, suggest it.
3. Do not silently assume model knowledge is current for any entry on this list.

**This file goes stale.** Current as of May 2026. Update when you notice drift.
