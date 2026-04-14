---
name: bash-script-generator
description: Generates production-ready Bash scripts following TDD, Clean Code, SOLID, DRY, KISS, and YAGNI principles. Use when the user requests bash/shell script creation, automation scripts, or mentions shell scripting workflow.
---

# Bash Script Generation

## When to use this skill

Activate when the user wants to:
- Create a new Bash script following best practices
- Automate a task with a production-ready shell script
- Scaffold a script with proper structure, error handling, and tests
- Update or refactor an existing script to comply with Clean Code, SOLID, DRY, KISS, YAGNI

## Workflow

Copy this checklist and track progress:
```
Script Generation Progress:
- [ ] Phase 0: Input & Context
- [ ] Phase 1: Blueprint & Plan
- [ ] Phase 2: TDD Cycle (Red → Green → Refactor)
- [ ] Phase 3: Integration & Wiring
- [ ] Phase 4: Verification Loop
- [ ] Phase 5: Self-Review
- [ ] Phase 6: Handoff
```

---

## Phase 0: Input & Context

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root (`git rev-parse --show-toplevel`).

### Gather requirements

1. **Ask what the script should do:**
   > "What task should this script automate? Describe the inputs, expected outputs, and any external dependencies."

2. **Determine scope:**
   - Single-purpose utility or multi-step workflow?
   - Will it run interactively or in CI/CD?
   - Target shell: `bash` (default), `sh` (POSIX), `zsh`?

3. **Check for existing scripts:**
   ```bash
   find <workspace_root> -name "*.sh" -o -name "*.bash" 2>/dev/null | head -10
   ```

4. **Decision tree:**
   - **IF existing scripts found:** Analyze conventions (naming, structure, error handling patterns).
   - **IF no scripts:** Use the canonical structure from [assets/script-template.sh](assets/script-template.sh).

> [!CAUTION]
> **IF requirements are UNCLEAR → STOP. Ask clarifying questions. Do NOT assume or guess. Do NOT proceed until all ambiguities are resolved.**

### Analyze existing codebase

If modifying an existing script, analyze:
- Existing function decomposition
- Naming conventions (snake_case for functions/variables, UPPER_CASE for constants)
- Error handling approach (`set -e`, traps, manual checks)
- Argument parsing method (getopts, positional, manual)

> [!IMPORTANT]
> * **Adapt to existing project patterns.** Do not introduce new conventions unless explicitly requested.
> * **Do not violate clean code principles.**
> * **Do not violate SOLID principles.**
> * **Do not violate TDD principles.**
> * **Do not violate DRY principles.**
> * **Do not violate KISS principles.**
> * **Do not violate YAGNI principles.**

---

## Phase 1: Blueprint & Plan

### Script architecture

Decompose the requirement into single-responsibility functions:

| Component | Purpose | Rule |
|-----------|---------|------|
| `main()` | Orchestrator — delegates to other functions | ≤ 20 lines |
| `usage()` | Print help/usage text | Pure output, no logic |
| `parse_args()` | Argument parsing via `getopts` or positional | Only parsing, no side effects |
| `validate_input()` | Input validation and precondition checks | Fail-fast with clear messages |
| `<action>()` | Core business logic (one function per action) | ≤ 50 lines, single responsibility |
| `cleanup()` | Resource cleanup, temp file removal | Registered via `trap` |
| `log_*()` | Logging utilities (info, warn, error) | Output to stderr |

### Propose structure

Before proceeding, output:
```
I plan to create:
1. `script-name.sh` — Main script
   Functions: main, usage, parse_args, validate_input, <action>...
   Constants: <list readonly constants>
   Dependencies: <external tools required>

2. `test_script-name.bats` — BATS test file (if BATS available)

Proceed?
```

**Wait for user confirmation before Phase 2.**

---

## Phase 2: TDD Cycle

> [!IMPORTANT]
> **Do NOT generate implementation until tests are defined.**

### Step A: Skeleton Creation

Create the script shell without implementation:

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <arguments>

Description:
    <Brief description>

Options:
    -h, --help    Show this help message
EOF
}

main() {
    echo "Not implemented" >&2
    exit 1
}

main "$@"
```

### Step B: Red Phase (Write Failing Tests)

See [references/CHECKLIST.md](references/CHECKLIST.md) for testing patterns.

**If BATS is available**, write test file:
```bash
#!/usr/bin/env bats

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
SCRIPT_UNDER_TEST="${SCRIPT_DIR}/../script-name.sh"

@test "given_no_arguments_when_run_then_shows_usage" {
    run bash "$SCRIPT_UNDER_TEST"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "given_help_flag_when_run_then_shows_usage" {
    run bash "$SCRIPT_UNDER_TEST" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "given_valid_input_when_run_then_produces_expected_output" {
    run bash "$SCRIPT_UNDER_TEST" "valid_arg"
    [ "$status" -eq 0 ]
}
```

**If BATS is NOT available**, write manual test harness:
```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_UNDER_TEST="./script-name.sh"
PASS_COUNT=0
FAIL_COUNT=0

assert_exit_code() {
    local description="$1"
    local expected="$2"
    shift 2
    local actual
    "$@" >/dev/null 2>&1 && actual=0 || actual=$?
    if [[ "$actual" -eq "$expected" ]]; then
        echo "✅ PASS: ${description}"
        ((PASS_COUNT++))
    else
        echo "❌ FAIL: ${description} (expected=${expected}, actual=${actual})"
        ((FAIL_COUNT++))
    fi
}

assert_exit_code "no args shows usage" 1 bash "$SCRIPT_UNDER_TEST"
assert_exit_code "help flag exits 0" 0 bash "$SCRIPT_UNDER_TEST" -h

echo ""
echo "Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"
[[ "$FAIL_COUNT" -eq 0 ]] || exit 1
```

**Run tests — they MUST fail:**
```bash
bats test_script-name.bats
# or
bash test_script-name.sh
```

### Step C: Green Phase (Implementation)

Write minimal code to pass tests. Follow rules from [references/CODING_RULES.md](references/CODING_RULES.md).

**Required patterns:**
```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_PREFIX="[${SCRIPT_NAME}]"

log_info()  { echo "${LOG_PREFIX} INFO:  $*" >&2; }
log_warn()  { echo "${LOG_PREFIX} WARN:  $*" >&2; }
log_error() { echo "${LOG_PREFIX} ERROR: $*" >&2; }

cleanup() {
    local exit_code=$?
    # Remove temp files, release resources
    exit "$exit_code"
}
trap cleanup EXIT

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <arguments>

Description:
    <Brief description>

Options:
    -h, --help       Show this help message
    -v, --verbose    Enable verbose output
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
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
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
}

validate_input() {
    # Fail-fast with descriptive error messages
    :
}

main() {
    parse_args "$@"
    validate_input
    # Delegate to action functions
}

main "$@"
```

### Step D: Refactor

Apply coding rules checklist. See [references/CODING_RULES.md](references/CODING_RULES.md).

| Check | Action |
|-------|--------|
| Function > 50 lines | Extract into smaller functions |
| Duplicate logic | Extract to shared function |
| Magic strings/numbers | Extract to `readonly` constants |
| Missing `local` | Add `local` to all function variables |
| Unquoted variables | Quote all `"$variable"` references |
| Deep nesting > 3 | Refactor with early returns or guard clauses |

---

## Phase 3: Integration & Wiring

### Error handling

Every external command must handle failure:
```bash
# BAD — silent failure
cd /some/path

# GOOD — explicit failure handling
cd /some/path || { log_error "Failed to change to /some/path"; exit 1; }
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage/argument error |
| 126 | Permission denied |
| 127 | Command not found |

### Dependency checks

Validate external tool availability at startup:
```bash
require_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: ${cmd}"
        exit 127
    fi
}

require_command "jq"
require_command "curl"
```

### Temporary files

```bash
readonly TMP_DIR="$(mktemp -d)"
readonly TMP_FILE="$(mktemp)"

cleanup() {
    rm -rf "$TMP_DIR" "$TMP_FILE" 2>/dev/null || true
}
trap cleanup EXIT
```

---

## Phase 4: Verification Loop

**MAX_RETRIES = 3**

### Step 1: Syntax check

```bash
bash -n script-name.sh
```

### Step 2: ShellCheck lint

```bash
shellcheck -s bash script-name.sh
```

### Step 3: Run tests

```bash
bats test_script-name.bats
# or
bash test_script-name.sh
```

### Step 4: Permission check

```bash
chmod +x script-name.sh
ls -la script-name.sh
```

**Decision tree:**

| Condition | Action |
|-----------|--------|
| Syntax error | Fix and re-run |
| ShellCheck warning | Fix or add directive with justification |
| Tests fail | Debug and fix implementation |
| All pass | Proceed to Phase 5 |
| Retries > 3 | HALT. Report blocking issue to user. |

---

## Phase 5: Self-Review

Apply all rules from [references/CHECKLIST.md](references/CHECKLIST.md).

### Clean Code checklist

| Rule | Check |
|------|-------|
| Shebang | `#!/usr/bin/env bash` |
| Strict mode | `set -euo pipefail` |
| `local` keyword | All function variables use `local` |
| Quoting | All variables quoted `"$var"` |
| Constants | `readonly UPPER_CASE` |
| Function size | ≤ 50 lines each |
| Naming | `snake_case` functions/variables |
| No dead code | No commented-out blocks |
| No magic values | All literals extracted to constants |

### SOLID (SRP) verification

| Check | Question |
|-------|----------|
| SRP | Does each function do exactly ONE thing? |
| Function count | Is `main()` only an orchestrator? |
| Side effects | Are functions free of hidden side effects? |

### DRY verification

| Check | Question |
|-------|----------|
| Duplicate blocks | Any 3+ lines repeated? |
| Similar patterns | Can repeated logic be parameterized? |

### KISS verification

| Check | Question |
|-------|----------|
| Simplicity | Is this the simplest correct solution? |
| Over-engineering | Any single-use abstractions? |
| Unnecessary subshells | `$(echo "$var")` instead of `"$var"`? |

### YAGNI verification

| Check | Question |
|-------|----------|
| Unused functions | Is every function called? |
| Unused parameters | Is every parameter used? |
| Speculative features | Any "just in case" code? |

### Security verification

| Check | Question |
|-------|----------|
| Unquoted variables | Any `$var` without quotes? |
| `eval` usage | Forbidden unless justified |
| Temp files | Using `mktemp`? |
| Permissions | No `chmod 777`? |
| Hardcoded secrets | Using environment variables? |

---

## Phase 6: Handoff

Output summary:

```
✅ Script Generation Complete

Script: [script-name.sh]
Purpose: [Brief description]

Components Created:
- [List files]

TDD Cycle:
- Tests written: [count]
- Tests passing: [count]

Verification:
- bash -n: ✅ Pass
- shellcheck: ✅ Pass
- Tests: ✅ Pass

Ready for manual review.
```

---

## Critical constraints

> [!CAUTION]
> **Never execute a generated script without user permission.** Only run verification commands (syntax check, shellcheck, tests).

| Constraint | Rule |
|------------|------|
| Strict mode | `set -euo pipefail` is MANDATORY |
| Quoting | ALL variables MUST be quoted |
| Error handling | Every external command must handle failure |
| `eval` | FORBIDDEN unless user explicitly permits |
| `chmod 777` | FORBIDDEN |
| Hardcoded secrets | FORBIDDEN — use environment variables |
| Dead code | FORBIDDEN — no commented-out blocks |
| Magic values | FORBIDDEN — extract to `readonly` constants |
| Function size | ≤ 50 lines per function |
| Unclear requirements | STOP and ask questions |

---

## Tone & Style

- **Strict Architect.** No quick fixes. Production-ready only.
- **Architecture First.** Design function decomposition before coding.
- **TDD Discipline.** Tests before implementation.
- **Clarify First.** Ask questions when requirements are unclear.
- Follow `Rules for Agent` (Strict Architect Persona).
