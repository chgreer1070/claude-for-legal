# Citation Health

Periodic sweep of all citations used in recent research outputs.

## What it does

1. Collects all citations from recent Deep Research reports, briefs, and exports
2. Checks each citation's treatment status via the CoCounsel Legal MCP server
3. Produces aggregate health statistics (good / caution / negative / unresolved)
4. Compares against previous reports to identify degradation trends
5. Flags citations needing immediate attorney attention

## How it differs from authority-tracker

- **authority-tracker:** Monitors a curated watch list of specific relied-on citations
- **citation-health:** Sweeps broadly across all citations from the reporting period

Use authority-tracker for ongoing monitoring of key authorities.
Use citation-health for periodic portfolio-wide health checks.

## Architecture

```
citation-health (orchestrator, read-only)
├── citation-collector (read-only, MCP access, structured JSON output)
└── health-reporter (read + write, produces Markdown/HTML report)
```

## Deployment

```bash
bash scripts/deploy-managed-agent.sh citation-health
```

## Steering examples

See `steering-examples.json` for input/output patterns.
