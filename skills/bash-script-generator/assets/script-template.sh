#!/usr/bin/env bash
set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_PREFIX="[${SCRIPT_NAME}]"
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_USAGE_ERROR=2
readonly EXIT_MISSING_DEPENDENCY=127

# ── Logging ──────────────────────────────────────────────────────────────────
log_info()  { echo "${LOG_PREFIX} INFO:  $*" >&2; }
log_warn()  { echo "${LOG_PREFIX} WARN:  $*" >&2; }
log_error() { echo "${LOG_PREFIX} ERROR: $*" >&2; }
log_debug() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "${LOG_PREFIX} DEBUG: $*" >&2
    fi
}

die() {
    log_error "$@"
    exit "$EXIT_GENERAL_ERROR"
}

# ── Cleanup ──────────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    log_debug "Cleaning up..."
    exit "$exit_code"
}
trap cleanup EXIT

# ── Functions ────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <arguments>

Description:
    Brief description of what this script does.

Options:
    -h, --help         Show this help message
    -v, --verbose      Enable verbose output

Examples:
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} -v -o result.txt input.txt

Exit Codes:
    0   Success
    1   General error
    2   Usage error
    127 Missing dependency
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit "$EXIT_SUCCESS"
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit "$EXIT_USAGE_ERROR"
                ;;
            *)
                break
                ;;
        esac
    done
}

validate_input() {
    log_debug "Validating input..."
}

do_work() {
    log_info "Starting..."
    log_info "Done."
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    parse_args "$@"
    validate_input
    do_work
}

main "$@"
