# Research Digest

Weekly summary of Deep Research activity across the team.

## What it does

1. Scans research history for sessions in the reporting period
2. Groups activity by practice area and jurisdiction
3. Calculates quota usage and projects trends
4. Identifies cross-matter research patterns
5. Produces a formatted digest and posts to Slack

## Architecture

```
research-digest (orchestrator, read-only)
├── activity-scanner (read-only, MCP access, structured JSON output)
└── digest-writer (read + write, produces Markdown/HTML digest)
```

## Deployment

```bash
bash scripts/deploy-managed-agent.sh research-digest
```

## Steering examples

See `steering-examples.json` for input/output patterns.
