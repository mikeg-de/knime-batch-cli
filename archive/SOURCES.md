# Upstream Sources & References

This document tracks all source repositories and references for the KNIME Batch Execution safeguard project.
Use these URLs for future fetches or to track upstream changes.

## Primary Source

| Source | URL | Status |
|--------|-----|--------|
| GitHub (canonical) | https://github.com/knime/knime-ap-batch | Active (as of 2026-04-13) |
| Bitbucket (mirror) | https://bitbucket.org/KNIME/knime-ap-batch/src/master/ | Active mirror |

### Branches (GitHub)
- `master` — main development branch
- `releases/STS` — short-term support release branch

### Tags (GitHub — superset of Bitbucket)
- `analytics-platform/5.5.0`
- `analytics-platform/5.10.0`
- `analytics-platform/5.11.0`

### Bitbucket-only artifacts
- `.lfsconfig` — Git LFS config pointing to `https://bitbucket.org/KNIME/knime-ap-batch.git/info/lfs` (not relevant for GitHub fork)
- Bitbucket has only 1 tag (`analytics-platform/5.5.0`); GitHub has all 3

## Community Repositories

### reneamendes/knime-headless
| Field | Value |
|-------|-------|
| URL | https://github.com/reneamendes/knime-headless |
| Type | Documentation-only (no code) |
| Created | 2024-08-09 |
| Stars | 1 |
| License | None specified |
| Value | Headless execution guide for Linux/Windows with exit codes, production PeopleSoft example |

Key content archived in `docs/reference-knime-headless.md`.

### nick-solly/knimer
| Field | Value |
|-------|-------|
| URL | https://github.com/nick-solly/knimer |
| Type | Docker + Terraform automation framework |
| Created | 2022-08-22 |
| Stars | 4 |
| License | MIT |
| Languages | HCL, Python, Dockerfile, Shell, Makefile |
| Value | Full AWS ECS Fargate batch execution pipeline with S3 workflow storage, Slack notifications, EventBridge scheduling |

Key content archived in `docs/reference-knimer.md`.

## KNIME Forum & Documentation

- [Update on Batch Execution in KNIME Analytics Platform](https://forum.knime.com/t/update-on-batch-execution-in-knime-analytics-platform/90965) — Official announcement of batch execution extraction to separate extension (AP 5.9+)
- [Batch Execution Forum Thread](https://forum.knime.com/t/batch-execution/16882) — Community discussion on batch mode
- [KNIME AP 5.9 Changelog](https://docs.knime.com/ap/latest/changelogs/5.9/) — Changelog documenting the extraction
- [Headless execution article by Marcus Lauber](https://medium.com/low-code-for-advanced-data-science/knime-batch-processing-on-windows-and-macos-caacde067bd0)
- [Archived KNIME FAQ on batch mode](https://web.archive.org/web/20231208203103/https://www.knime.com/faq#q12)

## KNIME SDK Setup (for building)
- GitHub: https://github.com/knime/knime-sdk-setup
- Bitbucket: https://bitbucket.org/KNIME/knime-sdk-setup

## Pull Request History

### Bitbucket PRs (earlier — initial extraction)
See `archive/bitbucket-pull-requests.json`

### GitHub PRs (later — ongoing development)
See `archive/pull-requests.json`

### Combined Timeline
1. 2025-11-12 — BB PR#1: Batch execution code+test moved from knime-core (Bernd Wiswedel)
2. 2025-11-13 — BB PR#2: Renamed update site category (Bernd Wiswedel)
3. 2025-11-26 — BB PR#3: Bump AP Parent POM to 5.10.0 (Leonard Woerteler)
4. 2025-12-04 — BB PR#4: Build pipeline adjustments (Madhu Subramanya)
5. 2025-12-31 — GH PR#1: Incremental version bumps for 5.10.0 (Leo Woerteler)
6. 2026-01-22 — GH PR#2: Fix logger name — AP-25551 (Manuel Hotz)
7. 2026-02-11 — GH PR#3: Version bumps for 5.11.0 [CLOSED] (Leo Woerteler)
8. 2026-02-11 — GH PR#4: Version bumps for 5.11.0 [MERGED] (Leo Woerteler)
9. 2026-02-26 — GH PR#5: Version bumps for 5.12.0 (Leo Woerteler)
10. 2026-03-11 — GH PR#6: Pipeline library branch update (Gabriel Einsdorf)
