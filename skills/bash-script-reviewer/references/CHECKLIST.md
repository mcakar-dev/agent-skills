# Script Review Checklist

Detailed review rules organized by principle. Reference this during Phase 2 analysis.

---

## P1: Security (CRITICAL)

| Check | Detection | Fix |
|-------|-----------|-----|
| Unquoted variables | `$var` instead of `"$var"` | Always quote: `"$variable"` |
| Command injection | `eval "$user_input"` | Avoid eval, use arrays |
| Unsafe temp files | `tmp=/tmp/myfile` | Use `mktemp` |
| World-writable | `chmod 777` | Use minimal permissions |
| Hardcoded secrets | Passwords in script | Use environment variables |

### Unquoted variable example

```bash
# BAD - Word splitting and glob expansion
for file in $files; do
    rm $file
done

# GOOD - Properly quoted
for file in "${files[@]}"; do
    rm -- "$file"
done
```

### Eval dangers

```bash
# BAD - Command injection vulnerability
user_input="foo; rm -rf /"
eval "echo $user_input"

# GOOD - No eval needed
echo "$user_input"
```

---

## P2: Clean Code (MAJOR/MINOR)

### Function extraction (SRP)

| Violation | Check | Severity |
|-----------|-------|----------|
| Long function | > 50 lines | MAJOR |
| Multiple responsibilities | Does more than one thing | MAJOR |
| Deep nesting | > 3 levels of if/for/while | MAJOR |
| No functions | Script without function definitions | MINOR |

```bash
# BAD - Mixed responsibilities
main() {
    # 100 lines of validation, processing, and output
}

# GOOD - Single responsibility
validate_input() { ... }
process_data() { ... }
output_results() { ... }

main() {
    validate_input "$@"
    process_data
    output_results
}
```

### Naming conventions

| Rule | Bad | Good |
|------|-----|------|
| Descriptive names | `x`, `tmp`, `data` | `user_count`, `temp_file` |
| Verb for functions | `user()` | `get_user()`, `create_user()` |
| Boolean prefix | `status` | `is_valid`, `has_permission` |
| Constants uppercase | `max_retries=5` | `MAX_RETRIES=5` |

### Readability

| Rule | Bad | Good |
|------|-----|------|
| Line length | > 120 characters | Break with `\` |
| Magic numbers | `if [[ $count -gt 5 ]]` | `MAX_RETRIES=5` |
| Missing local | `result=...` in function | `local result=...` |

---

## P3: DRY (MAJOR)

### Duplicate detection

| Pattern | Detection | Fix |
|---------|-----------|-----|
| Repeated code blocks | Same 3+ lines twice | Extract to function |
| Similar patterns | Same logic with minor diff | Parameterize |
| Copy-paste | Identical sections | Create utility function |

```bash
# BAD - Repeated pattern
echo "Processing file1.txt..."
process_file "file1.txt"
echo "Done with file1.txt"

echo "Processing file2.txt..."
process_file "file2.txt"
echo "Done with file2.txt"

# GOOD - Extracted function
process_with_logging() {
    local file="$1"
    echo "Processing $file..."
    process_file "$file"
    echo "Done with $file"
}

process_with_logging "file1.txt"
process_with_logging "file2.txt"
```

---

## P4: KISS (MAJOR/MINOR)

### Complexity indicators

| Violation | Detection | Severity |
|-----------|-----------|----------|
| Over-engineered | Simple task, complex solution | MAJOR |
| Unnecessary abstraction | Single-use function with 3 params | MINOR |
| Complex conditionals | > 3 conditions in one check | MAJOR |
| Unnecessary subshells | `$(echo "$var")` instead of `"$var"` | MINOR |

```bash
# BAD - Over-engineered
format_message() {
    local template="$1"
    local var1="$2"
    local var2="$3"
    printf "$template" "$var1" "$var2"
}
message=$(format_message "Hello %s, you have %s messages" "$name" "$count")

# GOOD - Simple
message="Hello $name, you have $count messages"
```

### Simplification patterns

```bash
# BAD - Unnecessary cat
content=$(cat file.txt | grep pattern)

# GOOD - Useless use of cat
content=$(grep pattern file.txt)

# BAD - Complex conditional
if [[ "$a" == "x" ]] || [[ "$a" == "y" ]] || [[ "$a" == "z" ]]; then

# GOOD - Pattern matching
if [[ "$a" =~ ^[xyz]$ ]]; then
```

---

## P5: YAGNI (MINOR)

### Unused code indicators

| Violation | Detection | Action |
|-----------|-----------|--------|
| Unused function | Never called | Remove |
| Commented code | Large comment blocks | Remove |
| Speculative params | Unused function parameters | Remove |
| Future features | TODO implementations | Remove until needed |

```bash
# BAD - YAGNI violation
process_file() {
    local file="$1"
    local format="$2"      # Never used
    local verbose="$3"     # Never used
    cat "$file"
}

# GOOD - Only what's needed
process_file() {
    local file="$1"
    cat "$file"
}
```

---

## P6: Error Handling (MAJOR)

### Required patterns

| Check | Bad | Good |
|-------|-----|------|
| Exit on error | No `set -e` | `set -eo pipefail` |
| Command check | Assuming success | Check `$?` or use `||` |
| Missing cleanup | No trap | `trap cleanup EXIT` |
| Silent failure | Failed command, no message | `|| { echo "Error"; exit 1; }` |

```bash
# BAD - No error handling
#!/bin/bash
cd /some/directory
rm -rf *

# GOOD - Proper error handling
#!/bin/bash
set -eo pipefail

cleanup() {
    echo "Cleaning up..."
}
trap cleanup EXIT

cd /some/directory || { echo "Failed to cd"; exit 1; }
rm -rf ./*
```

---

## P7: Script Structure (MINOR)

### Recommended structure

```bash
#!/usr/bin/env bash
# Brief description

set -eo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions (alphabetical or logical order)
cleanup() { ... }
process() { ... }
validate() { ... }

# Main
main() {
    validate "$@"
    process
}

main "$@"
```

### Structure violations

| Issue | Detection | Severity |
|-------|-----------|----------|
| No shebang | Missing `#!/bin/bash` | MINOR |
| No set options | Missing `set -e` | MAJOR |
| Mixed declarations | Functions after main code | MINOR |
| No main function | Script without main() | MINOR |
