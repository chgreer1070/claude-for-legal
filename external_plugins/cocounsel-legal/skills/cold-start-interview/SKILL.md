---
name: cocounsel-legal:cold-start-interview
version: 0.2.0
description: >
  Setup interview for the CoCounsel Legal plugin — captures research
  defaults, jurisdiction preferences, subscription tier, citation
  format, and cross-plugin routing. Use on a fresh install, when the
  user wants to redo their research profile, or to re-check MCP
  connector status. Runs without a populated CLAUDE.md.
argument-hint: "[--redo | --check-integrations]"
allowed-tools:
  - mcp
  - Bash
---

# /cocounsel-legal:cold-start-interview

1. Check `~/.claude/plugins/config/claude-for-legal/cocounsel-legal/CLAUDE.md`. If already populated and no `--redo`, ask before overwriting.
2. Follow the workflow below.
3. Run Part 0 (role check, MCP connectivity). Then walk the research profile sections.
4. Surface gaps. If the user doesn't know their subscription limits, note it and offer to leave `[PLACEHOLDER]`.
5. Migration: if a populated CLAUDE.md exists at `~/.claude/plugins/cache/claude-for-legal/cocounsel-legal/*/CLAUDE.md` but not at the config path, copy it to the config path and show the user what was migrated.
6. Write `~/.claude/plugins/config/claude-for-legal/cocounsel-legal/CLAUDE.md`. Date the footer.
7. Confirm with the user before finalizing: "Here's what I captured — anything wrong?"

## Flags

- `--redo` — re-run the full interview and overwrite the config.
- `--check-integrations` — re-scan MCP connectors and refresh the `## Available integrations` table without re-running the full interview.

When probing: only report ✓ if an MCP tool call actually succeeded. Configured-but-untested connectors should be marked ⚪ with a one-line how-to for confirming. Never report ✓ based on `.mcp.json` declarations alone.

---

# Cold-Start Interview: CoCounsel Legal

## Purpose

Every research query, every citation check, every brief draft reads from the research profile. If defaults aren't captured, every skill asks the same setup questions from scratch. This interview fills the profile once.

Unlike practice-area plugins (litigation, commercial, etc.), this plugin's setup is lighter — it configures research behavior, not a practice framework. The interview takes ~5 minutes, not 10–15.

## Cold-start check

Read `~/.claude/plugins/config/claude-for-legal/cocounsel-legal/CLAUDE.md`:
- **Does not exist** → start the interview.
- **Contains `<!-- SETUP PAUSED AT: -->`** → greet the user and offer to resume from that section.
- **Populated (no `[PLACEHOLDER]` in critical fields)** → greet with a summary of current config. Offer `--redo` or `--check-integrations`.

## Part 0: Role and connectivity

### 0a. Who's using this

Ask:

> "Before we set up CoCounsel Legal, one question: are you a lawyer or legal professional, or are you a non-lawyer who works with an attorney?"

Capture role. If non-lawyer, ask for attorney contact.

### 0b. MCP connectivity check

Test the CoCounsel Legal MCP server:
- Call `legal_research_start_deep_research` with a minimal test query (e.g., "test connectivity") and immediately note whether the server responds (even with an error about the query — a response means connectivity works).
- If the server is not connected, stop and say:

> "The CoCounsel Legal MCP server isn't connected. You'll need a CoCounsel Legal subscription with the MCP connector enabled. Contact cocounselsupport@tr.com to set it up, then come back and run this setup again."

- If connected, report ✓ and continue.

Check optional integrations:
- **Slack** — attempt a test call if the Slack MCP server is configured. Report ✓, ✗, or ⚪.
- **Document storage** — check if Google Drive, SharePoint, or Box MCP servers are available.

### 0c. Shared company profile

Check `~/.claude/plugins/config/claude-for-legal/company-profile.md`:
- If it exists and is populated, read it and confirm: "I see you're at [company name] in [industry]. Is that still right?"
- If it doesn't exist, ask the basics: company name, industry, core jurisdictions. Write `company-profile.md`.

## Part 1: Research defaults

### 1a. Default jurisdictions

> "Which jurisdictions do you research most often? I can set up to 3 as defaults so you don't have to specify them every time. Examples: California, New York, Federal (9th Circuit)."

If the user names more than 3, note the limit and ask them to pick their top 3.

### 1b. Practice areas

> "What practice areas do you focus on? This helps me route research to the right follow-up tools. For example: employment law, IP litigation, commercial contracts, regulatory compliance."

### 1c. Report format preference

> "When I deliver a Deep Research report, would you prefer:
> 1. **Verbatim** — the raw Westlaw report, exactly as delivered (default)
> 2. **Memo** — automatically reformatted as a research memo
> 3. **Brief section** — automatically reformatted for insertion into a brief
> 4. **Executive summary** — one-page overview
>
> You can always ask for a different format after delivery. This just sets the default."

### 1d. Citation format

> "For brief sections and memos, which citation format?
> 1. **Bluebook** (default)
> 2. **ALWD**
> 3. **Your firm's house style** — if so, tell me what's different from Bluebook."

If house style, capture the deviations.

## Part 2: Subscription & quota

> "Do you know your CoCounsel Legal subscription tier? This helps the quota tracker give you accurate usage reports. If you're not sure, I'll leave it blank and you can fill it in later.
>
> - **Plan name:** standard / professional / enterprise / don't know
> - **Daily query limit:** (e.g., 50)
> - **Monthly query limit:** (e.g., 500)
> - **Max concurrent sessions:** (e.g., 3)"

If the user doesn't know, leave as `[PLACEHOLDER]` — quota-tracker will still work, it just won't show limits.

> "When should I warn you about quota? Default is 80% of monthly limit. Want a different threshold?"

## Part 3: Cross-plugin routing

> "CoCounsel Legal integrates with other practice-area plugins. I'll check which ones are installed and set up routing."

Scan for installed practice-area plugins by checking for CLAUDE.md files in sibling directories:
- `litigation-legal`
- `commercial-legal`
- `regulatory-legal`
- `ip-legal`
- `employment-legal`
- `corporate-legal`
- `privacy-legal`

For each installed plugin, add it to the routing table. For uninstalled plugins, note it as unavailable.

## Part 4: Authority watch list (optional)

> "Do you have any citations you want to monitor for negative treatment? The authority-tracker agent can check them on a schedule and alert you if a case you rely on gets distinguished, overruled, or otherwise weakened.
>
> You can add these now or later. Just paste citations in any format."

If the user provides citations, add them to the watch list.

## Part 5: Write the profile

Assemble the captured data into the CLAUDE.md template structure:
1. Fill all `[PLACEHOLDER]` fields with captured values
2. Mark uncaptured fields as `[not configured]` (not `[PLACEHOLDER]` — distinguishes "asked and skipped" from "never asked")
3. Date the file: `*Written by cold-start on YYYY-MM-DD.*`
4. Write to `~/.claude/plugins/config/claude-for-legal/cocounsel-legal/CLAUDE.md`
5. Show the user a summary and ask: "Here's what I captured — anything wrong?"

If the user wants changes, make them and rewrite. Then confirm:

> "Setup complete. Your research defaults are saved. Every CoCounsel Legal skill will read these preferences automatically. You can edit them anytime at `~/.claude/plugins/config/claude-for-legal/cocounsel-legal/CLAUDE.md` or re-run `/cocounsel-legal:cold-start-interview --redo`."
