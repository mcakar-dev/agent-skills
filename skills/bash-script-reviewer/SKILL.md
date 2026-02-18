---
name: bash-script-reviewer
description: Reviews shell scripts for Clean Code, SOLID, DRY, KISS, and YAGNI violations. Use when the user requests script review, mentions bash/shell code quality, or wants to fix script issues.
---

# Script Review

## When to use this skill

Activate when the user wants to:
- Review shell scripts (Bash, Zsh, sh)
- Analyze script quality and maintainability
- Fix violations of Clean Code, SOLID, DRY, KISS, YAGNI
- Perform security audit on scripts
- Refactor complex scripts

## Workflow

Copy this checklist and track progress:
```
Script Review Progress:
- [ ] Phase 0: Check Input
- [ ] Phase 1: Scope Extraction
- [ ] Phase 2: Analysis
- [ ] Phase 3: Reporting
- [ ] Phase 4: Verification
- [ ] Phase 5: Action Triggers
```

---

## Phase 0: Check Input

1. Check if the user provided specific script file(s) to review.
2. **IF specific input provided:** Skip Phase 1, proceed to Phase 2.
3. **IF no input:** Proceed to Phase 1.

---

## Phase 1: Scope Extraction

### Fetch changes

```bash
git diff --staged --name-only -- "*.sh" "*.bash" "*.zsh"
```

**Decision tree:**
- **IF empty:** STOP. Output: `"No staged script changes found. Please stage your changes (git add) or specify the script path to review."`
- **IF files found:** Proceed.

### Retrieve diff

```bash
git diff --staged -- "*.sh" "*.bash" "*.zsh"
```

For specific paths:
```bash
git diff <path>
```

### Exclusion filters

Ignore these patterns:
- `node_modules/`, `vendor/`
- `.git/hooks/` (unless explicitly requested)
- Generated scripts

**Strict Rule:** Only review modified lines + 5 lines of context for full understanding.

---

## Phase 2: Analysis

Evaluate every change against these criteria. See [references/CHECKLIST.md](references/CHECKLIST.md) for detailed rules.

### Priority order

| Priority | Category | Examples |
|----------|----------|----------|
| **P1** | Security | Command injection, unquoted variables, eval usage |
| **P2** | Clean Code | Function extraction, naming, readability |
| **P3** | DRY | Duplicate code blocks, repeated patterns |
| **P4** | KISS | Over-engineering, unnecessary complexity |
| **P5** | YAGNI | Unused functions, speculative features |

### Core principle checks

| Principle | Question to Ask |
|-----------|-----------------|
| **Clean Code** | Is the intent immediately clear? |
| **SOLID/SRP** | Does each function do ONE thing? |
| **DRY** | Is any logic duplicated? |
| **KISS** | Is this the simplest solution? |
| **YAGNI** | Is this feature actually needed now? |

---

## Phase 3: Reporting

**Do not summarize. Do not praise.** Output strictly in this format:

Use template: [assets/review-template.md](assets/review-template.md)

### Issue block format

```markdown
**File:** `[path/to/script.sh]`

> **Code Under Review:**
> ```bash
> # The specific lines that are problematic
> function bad_function() { ... }
> ```

* **Severity:** `[CRITICAL / MAJOR / MINOR]`
* **Principle:** `[CLEAN_CODE / SOLID / DRY / KISS / YAGNI / SECURITY]`
* **Issue:** [Concise explanation of *why* this violates the principle.]
* **Correction:**
    ```bash
    # The fixed version
    ```

---
```

### Severity definitions

| Severity | Criteria |
|----------|----------|
| **CRITICAL** | Security vulnerability, data loss risk, script breakage |
| **MAJOR** | Principle violation, maintainability problem, potential bugs |
| **MINOR** | Style issue, minor optimization, readability improvement |

---

## Phase 4: Verification

1. **Silence on Success:** If a file adheres to all rules, output: `✅ [Filename]: No issues found.`
2. **No Fluff:** Do not output phrases like "Overall good job" or "Nice script."
3. **Actionable Negatives Only:** Only output problems with solutions.

---

## Phase 5: Action Triggers

After listing all issues, end with:

```
I have identified [X] issues ([Y] CRITICAL, [Z] MAJOR, [W] MINOR).

Would you like me to:
1. Apply all fixes automatically?
2. Show detailed explanation for specific issues?
3. Refactor the entire script following best practices?
```

---

## Quick reference

### Common commands

| Action | Command |
|--------|---------|
| Staged script changes | `git diff --staged -- "*.sh"` |
| File names only | `git diff --staged --name-only -- "*.sh"` |
| Specific file | `git diff <path>` |
| Syntax check | `bash -n script.sh` |
| Lint with shellcheck | `shellcheck script.sh` |

### Severity quick guide

| Find | Severity | Principle |
|------|----------|-----------|
| Unquoted `$variable` | CRITICAL | SECURITY |
| `eval` usage | CRITICAL | SECURITY |
| Function > 50 lines | MAJOR | CLEAN_CODE |
| Duplicated code block | MAJOR | DRY |
| Nested if > 3 levels | MAJOR | KISS |
| Unused function | MINOR | YAGNI |
| Magic numbers | MINOR | CLEAN_CODE |
| No error handling | MAJOR | CLEAN_CODE |

---

## Tone & Style

- **Radical Candor.** No fluff. No pleasantries. Go straight to flaws.
- **Strict Technical Lead.** Do not use "Great job" or "Nice script."
- **Teach on CRITICAL.** Explain security/architectural implications for every critical issue.
- **Provide working solutions.** Every issue must have a correction.
