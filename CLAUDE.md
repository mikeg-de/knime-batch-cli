# CLAUDE.md

This file provides guidance to Claude Code when working with the KNIME Batch CLI project.

## Project Overview

**Type:** Safeguard fork + CLI wrapper
**Purpose:** Preserve KNIME batch execution source code and provide CLI shortcuts for headless workflow execution
**Upstream:** Fork of [knime/knime-ap-batch](https://github.com/knime/knime-ap-batch) (GPL v3)
**Language:** Java 17 (OSGi/Eclipse/Tycho), Shell scripts

## Why This Fork Exists

KNIME AG is removing built-in batch execution support from the Analytics Platform. Starting with AP 5.9,
the batch executor became a separate extension. This fork preserves the code and adds CLI tooling
for continued headless usage without depending on KNIME's extension marketplace or KNIME Pro.

## Directory Structure

```
├── org.knime.ap.batch/                 # Core OSGi bundle — BatchExecutorImpl.java
├── org.knime.ap.batch.tests/           # JUnit 5 tests + test workflow ZIPs
├── org.knime.features.ap.batch/        # Eclipse feature descriptor
├── org.knime.update.ap.batch/          # P2 update site (category.xml)
├── scripts/                            # CLI wrapper scripts (our additions)
├── docs/                               # Reference docs from community repos
├── archive/                            # PR metadata, sources list
├── pom.xml                             # Root POM (Tycho reactor build)
└── Jenkinsfile                         # KNIME CI pipeline (upstream)
```

## Key Files

- `org.knime.ap.batch/src/org/knime/ap/batch/BatchExecutorImpl.java` — The entire batch executor
  implementation (~900 lines). Handles argument parsing, workflow loading, execution, saving.
- `org.knime.ap.batch/META-INF/MANIFEST.MF` — OSGi bundle config, version, dependencies
- `org.knime.ap.batch/OSGI-INF/BatchApplicationService.xml` — Registers as `IBatchExecutor` service
- `scripts/knime-batch.sh` — Linux/WSL CLI wrapper with auto-detection
- `scripts/knime-batch.bat` — Windows CLI wrapper

## Build

This is an Eclipse/Tycho project. Building requires KNIME's P2 repositories:

```bash
mvn clean verify -Pbuild
```

The build resolves against KNIME's Target Platform, shared plugins, core, and product repositories.
Parent POM: `org.knime.maven:ap.parent:5.10.0`

## Git Workflow

```bash
# Track upstream changes
git fetch upstream
git log upstream/master --oneline -10

# Push to our fork (WSL)
powershell.exe -Command "cd 'E:\git\knime-batch-cli'; git push"
```

**Remotes:**
- `origin` → `https://github.com/mikeg-de/knime-batch-cli.git`
- `upstream` → `https://github.com/knime/knime-ap-batch.git`

**Branches:**
- `master` — main development (tracks upstream)
- `releases/STS` — short-term support release

**Tags:**
- `analytics-platform/5.5.0`, `analytics-platform/5.10.0`, `analytics-platform/5.11.0`

## CLI Wrapper

The wrapper scripts auto-detect KNIME installation and provide shortcuts:

```bash
knime-batch run <workflow>     # Execute
knime-batch load <workflow>    # Load-only (validate)
knime-batch test <workflow>    # Execute without saving
knime-batch help               # Show usage
```

## Archived References

- `archive/SOURCES.md` — All upstream URLs for future fetches
- `archive/pull-requests.json` — GitHub PR history
- `archive/bitbucket-pull-requests.json` — Bitbucket PR history (earlier, initial extraction)
- `docs/reference-knime-headless.md` — Community headless execution patterns
- `docs/reference-knimer.md` — Docker/Terraform automation patterns

## Output Style

Respond terse. All technical substance stays. Only fluff dies.
Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging.
Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact.
Pattern: `[thing] [action] [reason]. [next step].`
Exception — use full prose for: security warnings, irreversible action confirmations, multi-step sequences where fragment ambiguity risks misread, user confused or repeating question.
Code, commits, PRs, documentation files (HANDOFF.md, DECISIONS.md, LEARNINGS.md, SESSION_LOG.md, memory files): write normal.
