#!/usr/bin/env bash
# knime-batch.sh — Wrapper for KNIME headless/batch execution
# Simplifies the long command line into ergonomic shortcuts.
#
# Usage:
#   knime-batch run <workflow-dir-or-zip> [options]
#   knime-batch load <workflow-dir-or-zip>           # Load-only (no execute)
#   knime-batch test <workflow-dir-or-zip>            # Execute without saving
#   knime-batch help
#
# Environment:
#   KNIME_HOME   — Path to KNIME installation directory (auto-detected if not set)
#   KNIME_PREFS  — Path to preferences file (optional)

set -euo pipefail

# --- KNIME Installation Detection ---

detect_knime() {
    # Explicit override
    if [[ -n "${KNIME_HOME:-}" ]]; then
        KNIME_EXE="${KNIME_HOME}/knime"
        if [[ -x "$KNIME_EXE" ]]; then
            return 0
        fi
        echo "ERROR: KNIME_HOME set to '$KNIME_HOME' but no executable found" >&2
        return 1
    fi

    # Common Linux locations
    local candidates=(
        "/opt/knime/knime"
        "/usr/local/knime/knime"
        "$HOME/knime/knime"
        "$HOME/KNIME/knime"
    )

    # Glob for versioned installations
    for dir in /opt/knime_* /usr/local/knime_* "$HOME"/knime_* "$HOME"/KNIME_*; do
        [[ -d "$dir" ]] && candidates+=("$dir/knime")
    done

    # WSL: Check Windows-side installations
    if [[ -d "/mnt/c" ]]; then
        for dir in /mnt/c/Program\ Files/KNIME* /mnt/c/Users/*/knime_* /mnt/c/knime_*; do
            [[ -d "$dir" ]] && candidates+=("$dir/knime.exe")
        done
    fi

    # PATH lookup
    local path_knime
    path_knime=$(command -v knime 2>/dev/null || true)
    [[ -n "$path_knime" ]] && candidates+=("$path_knime")

    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            KNIME_EXE="$candidate"
            return 0
        fi
    done

    echo "ERROR: Cannot find KNIME installation. Set KNIME_HOME or add knime to PATH." >&2
    return 1
}

# --- Argument Building ---

build_args() {
    local workflow="$1"
    shift
    local args=()

    args+=("-nosplash")
    args+=("-consoleLog")

    # Determine workflow input type
    if [[ -f "$workflow" ]]; then
        args+=("-workflowFile=$workflow")
    elif [[ -d "$workflow" ]]; then
        args+=("-workflowDir=$workflow")
    else
        echo "ERROR: '$workflow' is neither a file nor directory" >&2
        return 1
    fi

    # Add preferences if set
    if [[ -n "${KNIME_PREFS:-}" ]]; then
        args+=("-preferences=$KNIME_PREFS")
    fi

    # Pass through remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--var)
                # Shorthand: -v name=value,type → -workflow.variable=name,value,type
                shift
                args+=("-workflow.variable=$1")
                ;;
            -c|--credential)
                shift
                args+=("-credential=$1")
                ;;
            -o|--output)
                shift
                if [[ "$1" == *.zip ]]; then
                    args+=("-destFile=$1")
                else
                    args+=("-destDir=$1")
                fi
                ;;
            --masterkey)
                shift
                args+=("-masterkey=$1")
                ;;
            --fail-on-load-error)
                args+=("-failonloaderror")
                ;;
            --update-links)
                args+=("-updateLinks")
                ;;
            -*)
                # Pass through native KNIME flags directly
                args+=("$1")
                ;;
            *)
                echo "WARNING: Unknown argument '$1', passing through" >&2
                args+=("$1")
                ;;
        esac
        shift
    done

    echo "${args[@]}"
}

# --- Commands ---

cmd_run() {
    local workflow="$1"
    shift
    local args
    args=$(build_args "$workflow" "$@")
    echo ">>> $KNIME_EXE $args" >&2
    eval "$KNIME_EXE" $args
}

cmd_load() {
    local workflow="$1"
    shift
    local args
    args=$(build_args "$workflow" "$@")
    echo ">>> $KNIME_EXE $args -noexecute -nosave" >&2
    eval "$KNIME_EXE" $args -noexecute -nosave
}

cmd_test() {
    local workflow="$1"
    shift
    local args
    args=$(build_args "$workflow" "$@")
    echo ">>> $KNIME_EXE $args -nosave -reset" >&2
    eval "$KNIME_EXE" $args -nosave -reset
}

cmd_help() {
    cat <<'USAGE'
knime-batch — KNIME headless/batch execution wrapper

COMMANDS
  run  <workflow>  [opts]   Execute workflow (default: save in place)
  load <workflow>  [opts]   Load-only validation (no execute, no save)
  test <workflow>  [opts]   Execute without saving (dry run)
  help                      Show this help

OPTIONS
  -v, --var NAME=VALUE,TYPE       Set workflow variable
  -c, --credential NAME;LOGIN;PW  Set credential
  -o, --output PATH               Save result to file (.zip) or directory
  --masterkey KEY                  Set encryption master key
  --fail-on-load-error             Abort on workflow load errors
  --update-links                   Update metanode links before execution
  -reset                           Reset workflow before execution
  -nosave                          Don't save after execution

  Any unrecognized -flag is passed through to KNIME directly.

ENVIRONMENT
  KNIME_HOME    Path to KNIME installation (auto-detected if unset)
  KNIME_PREFS   Path to Eclipse/KNIME preferences file

EXIT CODES
  0   Successful execution
  2   Parameters wrong or missing
  3   Error during workflow loading
  4   Error during execution

EXAMPLES
  # Execute a workflow from a ZIP file
  knime-batch run /path/to/workflow.zip

  # Execute with variables and save to new location
  knime-batch run /path/to/workflow/ \
    -v "outputFile,/tmp/result.csv,String" \
    -v "maxRows,100,int" \
    -o /tmp/executed-workflow.zip

  # Validate a workflow loads correctly
  knime-batch load /path/to/workflow.zip --fail-on-load-error

  # Test-run without saving
  knime-batch test /path/to/workflow/ -v "mode,test,String"

  # Pass credentials
  knime-batch run /path/to/workflow.zip \
    -c "database;dbuser;dbpass" \
    -c "api_key;apiuser;secret123"
USAGE
}

# --- Main ---

detect_knime

case "${1:-help}" in
    run)  shift; cmd_run "$@" ;;
    load) shift; cmd_load "$@" ;;
    test) shift; cmd_test "$@" ;;
    help|--help|-h) cmd_help ;;
    *)
        echo "Unknown command: $1" >&2
        cmd_help >&2
        exit 1
        ;;
esac
