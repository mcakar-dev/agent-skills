# Bash Coding Rules

Production-ready patterns and anti-patterns for Bash scripts. Reference this during Phase 2 (Green Phase) and Phase 5 (Self-Review).

---

## R1: Argument Parsing

### `getopts` pattern (short options)

```bash
parse_args() {
    while getopts ":hvo:f:" opt; do
        case "$opt" in
            h) usage; exit 0 ;;
            v) VERBOSE=true ;;
            o) OUTPUT_FILE="$OPTARG" ;;
            f) INPUT_FILE="$OPTARG" ;;
            :) die "Option -${OPTARG} requires an argument" ;;
            ?) die "Unknown option: -${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1))
    POSITIONAL_ARGS=("$@")
}
```

### Long option pattern (manual parsing)

```bash
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)    usage; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -o|--output)
                [[ -n "${2:-}" ]] || die "--output requires a value"
                OUTPUT_FILE="$2"; shift 2
                ;;
            --)           shift; break ;;
            -*)           die "Unknown option: $1" ;;
            *)            break ;;
        esac
    done
    POSITIONAL_ARGS=("$@")
}
```

---

## R2: Logging

### Standard logging functions

```bash
readonly LOG_PREFIX="[$(basename "${BASH_SOURCE[0]}")]"

log_info()  { echo "${LOG_PREFIX} INFO:  $*" >&2; }
log_warn()  { echo "${LOG_PREFIX} WARN:  $*" >&2; }
log_error() { echo "${LOG_PREFIX} ERROR: $*" >&2; }
log_debug() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "${LOG_PREFIX} DEBUG: $*" >&2
    fi
}
```

### Rules

| Rule | Rationale |
|------|-----------|
| Log to `stderr` | Keep `stdout` clean for piping |
| Include script name | Identify source in multi-script flows |
| Use log levels | Filter noise; debug only in verbose mode |

---

## R3: Error Handling Patterns

### `die()` utility

```bash
die() {
    log_error "$@"
    exit 1
}
```

### Guard clauses (early return / fail-fast)

```bash
validate_input() {
    [[ -n "${INPUT_FILE:-}" ]]    || die "Input file is required. Use -f <file>"
    [[ -f "$INPUT_FILE" ]]        || die "File not found: ${INPUT_FILE}"
    [[ -r "$INPUT_FILE" ]]        || die "File not readable: ${INPUT_FILE}"
}
```

### Command failure handling

```bash
# Pattern 1: Inline guard
cd "$target_dir" || die "Failed to change directory: ${target_dir}"

# Pattern 2: Conditional block
if ! output="$(some_command 2>&1)"; then
    die "Command failed: ${output}"
fi
```

---

## R4: Variable Discipline

### `local` keyword

Every variable inside a function MUST use `local`:

```bash
# BAD — leaks to global scope
process() {
    result="$(compute)"
    temp_file="/tmp/work"
}

# GOOD — scoped to function
process() {
    local result
    result="$(compute)"
    local temp_file="/tmp/work"
}
```

### Constants

Top-level constants MUST use `readonly`:

```bash
readonly MAX_RETRIES=3
readonly DEFAULT_TIMEOUT=30
readonly CONFIG_DIR="${HOME}/.config/myapp"
```

### Parameter expansion defaults

```bash
# Default value
output_dir="${OUTPUT_DIR:-/tmp}"

# Required value (fails if unset)
api_key="${API_KEY:?API_KEY environment variable is required}"
```

---

## R5: Array Handling

### Safe iteration

```bash
# BAD — word splitting
for file in $files; do ...

# GOOD — array iteration
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    process "$file"
done
```

### Building command arrays

```bash
# GOOD — safe argument construction
cmd=(curl -s -X POST)
cmd+=(-H "Content-Type: application/json")
cmd+=(-d "$payload")
cmd+=("$url")

"${cmd[@]}"
```

---

## R6: Temporary Resources

### Temp file pattern

```bash
readonly TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# Usage
local work_file="${TMP_DIR}/work.txt"
```

### Rules

| Rule | Bad | Good |
|------|-----|------|
| Temp file creation | `tmp="/tmp/myfile"` | `tmp="$(mktemp)"` |
| Temp dir creation | `mkdir /tmp/mydir` | `tmp_dir="$(mktemp -d)"` |
| Cleanup | Manual `rm` at end | `trap cleanup EXIT` |
| Naming | `/tmp/script_tmp` | `mktemp` with template |

---

## R7: Output Discipline

### Separation of concerns

| Stream | Purpose | Example |
|--------|---------|---------|
| `stdout` | Program output (data, results) | `echo "$result"` |
| `stderr` | Logs, progress, diagnostics | `log_info "Processing..."` |

### Structured output

```bash
# For machine-readable output, use consistent delimiters
print_record() {
    local name="$1"
    local value="$2"
    printf '%s\t%s\n' "$name" "$value"
}
```

---

## R8: Portability

### Shebang

```bash
# GOOD — portable
#!/usr/bin/env bash

# AVOID — hardcoded path
#!/bin/bash
```

### Bash-specific features (document when used)

| Feature | Bash Version | Portable Alternative |
|---------|-------------|---------------------|
| `[[ ]]` | 2.0+ | `[ ]` (POSIX) |
| `$(( ))` | 2.0+ | `expr` (POSIX) |
| Arrays | 2.0+ | None (POSIX has no arrays) |
| `{a..z}` | 3.0+ | `seq` or `while` loop |
| `|&` | 4.0+ | `2>&1 |` |

---

## R9: Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| `eval "$cmd"` | Command injection | Use arrays |
| `cat file \| grep` | Useless use of cat | `grep pattern file` |
| `echo $(command)` | Useless use of echo | `command` directly |
| `$( )` for assignment | `x=$(echo $y)` | `x="$y"` |
| Parsing `ls` output | Breaks on filenames with spaces | Use `find` or globs |
| `[ $var = val ]` | Breaks on empty/spaced values | `[[ "$var" == "val" ]]` |
| `for f in $(find)` | Word splitting | `find ... -exec` or `while read` |
| `cd && cmd && cd -` | Error-prone | Subshell `(cd dir && cmd)` |

### Safe `find` iteration

```bash
# BAD — breaks on spaces in filenames
for f in $(find . -name "*.txt"); do ...

# GOOD — null-delimited
while IFS= read -r -d '' file; do
    process "$file"
done < <(find . -name "*.txt" -print0)
```

---

## R10: Script Documentation

### Usage function (mandatory)

Every script MUST have a `usage()` function:

```bash
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <input_file>

Description:
    Process the input file and generate output.

Options:
    -h, --help         Show this help message
    -v, --verbose      Enable verbose output
    -o, --output FILE  Write output to FILE (default: stdout)

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
```

### Heredoc rules

| Rule | Bad | Good |
|------|-----|------|
| Indentation | `<<EOF` with tabs in content | `<<-EOF` with tab indentation |
| Variable expansion | `<<EOF` when vars unwanted | `<<'EOF'` to suppress expansion |
