# Bash Script Coding Checklist

Detailed rules organized by principle. Reference this during Phase 2 (TDD Cycle) and Phase 5 (Self-Review).

---

## C1: Script Structure

### Mandatory header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Rule | Severity |
|------|----------|
| Missing shebang | MAJOR |
| Missing `set -euo pipefail` | CRITICAL |
| Using `#!/bin/bash` instead of `#!/usr/bin/env bash` | MINOR |

### Required layout

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Constants ────────────────────────────────────────
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Logging ──────────────────────────────────────────
log_info()  { echo "[${SCRIPT_NAME}] INFO:  $*" >&2; }
log_warn()  { echo "[${SCRIPT_NAME}] WARN:  $*" >&2; }
log_error() { echo "[${SCRIPT_NAME}] ERROR: $*" >&2; }

# ── Cleanup ──────────────────────────────────────────
cleanup() { ... }
trap cleanup EXIT

# ── Functions (alphabetical or logical order) ────────
parse_args() { ... }
validate_input() { ... }
do_work() { ... }

# ── Main ─────────────────────────────────────────────
main() {
    parse_args "$@"
    validate_input
    do_work
}

main "$@"
```

| Violation | Severity |
|-----------|----------|
| Functions declared after main logic | MAJOR |
| No `main()` function | MAJOR |
| `main "$@"` missing at end | MAJOR |
| Interleaved declarations and logic | MINOR |

---

## C2: Clean Code

### Naming conventions

| Element | Convention | Bad | Good |
|---------|-----------|-----|------|
| Functions | `snake_case`, verb prefix | `data()` | `process_data()` |
| Variables | `snake_case` | `x`, `tmp` | `user_count`, `temp_file` |
| Constants | `UPPER_SNAKE_CASE`, `readonly` | `max=5` | `readonly MAX_RETRIES=5` |
| Booleans | `is_`/`has_` prefix | `valid` | `is_valid` |

### Function size

| Rule | Threshold | Severity |
|------|-----------|----------|
| Function body | ≤ 50 lines | MAJOR if violated |
| `main()` body | ≤ 20 lines (orchestrator only) | MAJOR if violated |

### Readability

| Rule | Bad | Good | Severity |
|------|-----|------|----------|
| Line length | > 120 chars | Break with `\` | MINOR |
| Magic numbers | `sleep 5` | `readonly WAIT_SECONDS=5; sleep "$WAIT_SECONDS"` | MAJOR |
| Missing `local` | `result=...` | `local result=...` | MAJOR |
| Unquoted vars | `echo $var` | `echo "$var"` | CRITICAL |

---

## C3: SOLID / SRP

Each function MUST do exactly one thing.

### SRP violations

```bash
# BAD — Mixed parsing, validation, and execution
main() {
    while getopts "f:o:" opt; do ... done
    [[ -f "$file" ]] || exit 1
    process "$file"
    echo "Done"
}

# GOOD — Separated concerns
parse_args() {
    while getopts "f:o:" opt; do ... done
}

validate_input() {
    [[ -f "$INPUT_FILE" ]] || { log_error "File not found: ${INPUT_FILE}"; exit 1; }
}

process_file() {
    # Single action
}

main() {
    parse_args "$@"
    validate_input
    process_file
}
```

### Dependency Inversion (for testability)

```bash
# BAD — Hardcoded dependency
process() {
    curl -s "https://api.example.com/data"
}

# GOOD — Injectable via variable/function
readonly API_URL="${API_URL:-https://api.example.com/data}"

fetch_data() {
    local url="$1"
    curl -s "$url"
}

process() {
    local data
    data="$(fetch_data "$API_URL")"
}
```

---

## C4: DRY

### Duplicate detection

| Pattern | Detection | Fix | Severity |
|---------|-----------|-----|----------|
| Same 3+ lines twice | Repeated block | Extract to function | MAJOR |
| Similar logic | Same pattern, different args | Parameterize | MAJOR |
| Repeated error pattern | Same `log_error; exit 1` | Create `die()` function | MINOR |

```bash
# BAD — Repeated error pattern
if [[ -z "$name" ]]; then
    echo "ERROR: name is required" >&2
    exit 1
fi
if [[ -z "$email" ]]; then
    echo "ERROR: email is required" >&2
    exit 1
fi

# GOOD — Extracted validation
require_var() {
    local var_name="$1"
    local var_value="$2"
    if [[ -z "$var_value" ]]; then
        log_error "${var_name} is required"
        exit 1
    fi
}

require_var "name" "$name"
require_var "email" "$email"
```

---

## C5: KISS

### Simplification rules

| Violation | Bad | Good | Severity |
|-----------|-----|------|----------|
| Useless cat | `cat file \| grep x` | `grep x file` | MINOR |
| Unnecessary subshell | `$(echo "$var")` | `"$var"` | MINOR |
| Complex conditional | `if [[ a ]] \|\| [[ b ]] \|\| [[ c ]]` | `case` or array lookup | MAJOR |
| Over-abstraction | Single-use wrapper function | Inline the logic | MINOR |

```bash
# BAD — Over-engineered
execute_command() {
    local cmd="$1"
    shift
    "$cmd" "$@"
}
execute_command grep "pattern" file.txt

# GOOD — Direct
grep "pattern" file.txt
```

---

## C6: YAGNI

### Dead code indicators

| Violation | Detection | Action | Severity |
|-----------|-----------|--------|----------|
| Unused function | Never called | Remove | MINOR |
| Commented code | Large comment blocks | Remove | MINOR |
| Unused parameters | Parameter declared but not used | Remove | MINOR |
| Speculative features | TODO blocks with implementation | Remove until needed | MINOR |
| Unused variables | Declared but never referenced | Remove | MINOR |

---

## C7: Error Handling

| Rule | Bad | Good | Severity |
|------|-----|------|----------|
| No `set -e` | Script continues on error | `set -euo pipefail` | CRITICAL |
| Silent `cd` | `cd /path` | `cd /path \|\| { log_error "..."; exit 1; }` | MAJOR |
| No cleanup | Temp files left behind | `trap cleanup EXIT` | MAJOR |
| Swallowed errors | `cmd 2>/dev/null` | Handle or log the error | MAJOR |

### `die()` pattern

```bash
die() {
    log_error "$@"
    exit 1
}

[[ -f "$config_file" ]] || die "Config not found: ${config_file}"
```

---

## C8: Security

| Rule | Bad | Good | Severity |
|------|-----|------|----------|
| Unquoted vars | `rm $file` | `rm -- "$file"` | CRITICAL |
| `eval` usage | `eval "$input"` | Avoid; use arrays | CRITICAL |
| Unsafe temp | `tmp=/tmp/myfile` | `tmp="$(mktemp)"` | CRITICAL |
| World-writable | `chmod 777` | `chmod 755` or less | CRITICAL |
| Hardcoded secrets | `PASSWORD="abc"` | `"${PASSWORD:?}"` | CRITICAL |
| Unsafe `rm` | `rm -rf $DIR/*` | `rm -rf "${DIR:?}/"*` | CRITICAL |

---

## C9: Testing Patterns (BATS)

### Test naming convention

Use `given_when_then` format:

```bash
@test "given_no_arguments_when_run_then_exits_with_error" { ... }
@test "given_valid_file_when_process_then_outputs_result" { ... }
@test "given_missing_dependency_when_check_then_exits_127" { ... }
```

### Test structure

```bash
@test "given_valid_input_when_process_then_succeeds" {
    # Arrange
    local input_file
    input_file="$(mktemp)"
    echo "test data" > "$input_file"

    # Act
    run bash "$SCRIPT_UNDER_TEST" "$input_file"

    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected"* ]]

    # Cleanup
    rm -f "$input_file"
}
```

### Edge cases to always test

| Scenario | Expected |
|----------|----------|
| No arguments | Non-zero exit + usage message |
| `-h` / `--help` | Exit 0 + usage message |
| Invalid option | Non-zero exit + error message |
| Missing file argument | Non-zero exit + error message |
| Empty input | Graceful handling |
