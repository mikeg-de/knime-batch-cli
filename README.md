# KNIME Batch CLI — Safeguard Fork

> **Fork of [knime/knime-ap-batch](https://github.com/knime/knime-ap-batch)** — preserved because KNIME AG is pulling
> built-in batch execution support from the Analytics Platform.

## Why This Exists

Starting with KNIME AP 5.9, the Batch Executor was extracted from the core product into a separate,
optional extension. KNIME's strategic direction points toward KNIME Pro (cloud-based, $12/hr compute)
for workflow automation. This fork safeguards the batch execution source code and provides CLI shortcuts
for continued headless KNIME usage independent of KNIME's extension marketplace.

**Timeline:**
- **AP 5.9** (2025-Q4): Batch execution extracted to separate extension (`knime-ap-batch`)
- **AP 5.10–5.12**: Extension maintained as installable add-on
- **Future**: Uncertain — KNIME promotes Pro as the replacement

## Repository Structure

```
├── org.knime.ap.batch/            # Core batch executor (Java, OSGi bundle)
│   └── src/.../BatchExecutorImpl.java  # Main implementation (~900 lines)
├── org.knime.ap.batch.tests/      # JUnit 5 test suite + test workflow ZIPs
├── org.knime.features.ap.batch/   # Eclipse feature definition (GPL v3)
├── org.knime.update.ap.batch/     # P2 update site configuration
├── scripts/
│   ├── knime-batch.sh             # Linux/macOS/WSL CLI wrapper
│   └── knime-batch.bat            # Windows CLI wrapper
├── docs/
│   ├── reference-knime-headless.md  # Headless execution patterns (archived from community)
│   └── reference-knimer.md          # Docker/Terraform automation patterns (archived from community)
├── archive/
│   ├── SOURCES.md                 # All upstream sources + fetch URLs
│   ├── pull-requests.json         # GitHub PRs (6 total)
│   └── bitbucket-pull-requests.json  # Bitbucket PRs (4 earlier, initial extraction)
├── pom.xml                        # Maven/Tycho build (parent: org.knime.maven:ap.parent)
└── CLAUDE.md                      # AI harness instructions
```

## CLI Wrapper Usage

The `scripts/knime-batch.sh` (Linux/WSL) and `scripts/knime-batch.bat` (Windows) wrappers
simplify the verbose KNIME batch command line:

```bash
# Execute a workflow
knime-batch run /path/to/workflow.zip

# Execute with variables
knime-batch run /path/to/workflow/ \
  -v "outputFile,/tmp/result.csv,String" \
  -v "maxRows,100,int"

# Load-only validation
knime-batch load /path/to/workflow.zip --fail-on-load-error

# Test run (execute without saving)
knime-batch test /path/to/workflow/ -v "mode,test,String"

# With credentials
knime-batch run /path/to/workflow.zip -c "database;user;pass"
```

Set `KNIME_HOME` to your KNIME installation directory, or let the script auto-detect it.

## Batch Executor CLI Reference

The underlying KNIME batch executor accepts these arguments:

| Flag | Description |
|------|-------------|
| `-workflowFile=PATH` | Input workflow as ZIP file |
| `-workflowDir=PATH` | Input workflow as directory |
| `-destFile=PATH` | Save executed workflow as ZIP |
| `-destDir=PATH` | Save executed workflow to directory |
| `-nosave` | Don't save after execution |
| `-reset` | Reset workflow before execution |
| `-noexecute` | Load only, don't execute |
| `-nosplash` | Suppress splash screen |
| `-consoleLog` | Log to console (stdout) |
| `-failonloaderror` | Fail if workflow has load errors |
| `-updateLinks` | Update metanode links |
| `-workflow.variable=NAME,VALUE,TYPE` | Set workflow variable (String/int/double) |
| `-credential=NAME;LOGIN;PASSWORD` | Set credential |
| `-masterkey=KEY` | Set encryption master key |
| `-preferences=PATH` | Load Eclipse preferences file |
| `-option=NODEID,NAME,VALUE,TYPE` | Set node option |

**Exit codes:** 0=success, 2=bad parameters, 3=load error, 4=execution error

## Building from Source

Requires Java 17+ and Maven with Tycho. The build depends on KNIME's P2 repositories:

```bash
mvn clean verify -Pbuild
```

See [knime-sdk-setup](https://github.com/knime/knime-sdk-setup) for full development environment setup.

## Upstream Tracking

```bash
# Fetch latest from KNIME upstream
git fetch upstream
git diff master upstream/master

# Merge upstream changes
git merge upstream/master
```

## License

GNU General Public License v3 with KNIME additional permissions (see `LICENSE` and individual module licenses).

## Archived Sources

See `archive/SOURCES.md` for all upstream URLs, community references, and PR history.
Fork/mirror URLs for future fetches:
- **GitHub:** https://github.com/knime/knime-ap-batch
- **Bitbucket:** https://bitbucket.org/KNIME/knime-ap-batch
- **Community — knime-headless:** https://github.com/reneamendes/knime-headless
- **Community — knimer:** https://github.com/nick-solly/knimer
