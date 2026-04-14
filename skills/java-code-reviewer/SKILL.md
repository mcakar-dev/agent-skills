---
name: java-code-reviewer
description: Reviews Java code for Clean Code, OOP, SOLID, and Design Pattern violations. Use when the user requests code review, mentions staged changes, security audit, or architecture analysis for Java/Spring Boot projects.
---

# Java Code Review

## When to use this skill

Activate when the user wants to:
- Review staged git changes (`git diff --staged`)
- Analyze specific Java files or classes
- Perform security or architecture audit
- Check code against Clean Code and SOLID principles

## Workflow

Copy this checklist and track progress:
```
Code Review Progress:
- [ ] Phase 0: Check Input
- [ ] Phase 1: Scope Extraction
- [ ] Phase 2: Analysis
- [ ] Phase 3: Reporting
- [ ] Phase 4: Verification
- [ ] Phase 5: Output
- [ ] Phase 6: Action Triggers
```

---

## Phase 0: Check Input

1. Check if the user provided specific file(s) or code to review.
2. **IF specific input provided:** Skip Phase 1, proceed to Phase 2.
3. **IF no input:** Proceed to Phase 1.

---

## Phase 1: Scope Extraction

### Fetch changes

```bash
git diff --staged --name-only
```

**Decision tree:**
- **IF empty:** STOP. Output: `"No staged changes found. Please stage your changes (git add) or specify the file/class path to review."`
- **IF files found:** Proceed.

### Retrieve diff

```bash
git diff --staged
```

For specific paths:
```bash
git diff <path>
```

### Exclusion filters

Ignore these patterns:
- `target/`, `build/`, `.gradle/`
- `.idea/`, `.vscode/`, `.settings/`
- `*.generated.java`, `*_.java` (MapStruct)
- `node_modules/`, `dist/`

**Strict Rule:** Only review modified lines + 3 lines of context. If a 500-line file has 1 changed line, review ONLY that line and its architectural impact.

---

## Phase 2: Analysis

Evaluate every change against these criteria. See [references/CHECKLIST.md](references/CHECKLIST.md) for detailed rules.

### Priority order

| Priority | Category | Examples |
|----------|----------|----------|
| **P1** | Security | SQL Injection, XSS, thread-safety, sensitive data exposure |
| **P2** | Architecture | SOLID violations, layer breaches, tight coupling |
| **P3** | Performance | N+1 queries, inefficient streams, memory leaks |
| **P4** | Clean Code | Naming, DRY, magic literals, error handling |

### Spring Boot specific checks

| Rule | Violation | Severity |
|------|-----------|----------|
| Constructor Injection | `@Autowired` on fields | CRITICAL |
| No static imports | `import static` in production | MAJOR |
| Exception handling | Catching generic `Exception` | MAJOR |
| Empty catch blocks | `catch (Exception e) { }` | CRITICAL |
| Missing final | Non-final injected dependencies | MINOR |

### Anti-patterns

See [references/PATTERNS.md](references/PATTERNS.md) for common anti-patterns and fixes.

---

## Phase 3: Reporting

**Do not summarize. Do not praise.** Output strictly in this format:

Use template: [assets/review-template.md](assets/review-template.md)

### Issue block format

```markdown
**File:** `[Path/To/File.java]`

> **Code Under Review:**
> ```java
> // The specific lines from the diff that are problematic
> public void badMethod() { ... }
> ```

* **Severity:** `[CRITICAL / MAJOR / MINOR]`
* **Issue:** [Concise explanation of *why* this is wrong. Reference SOLID/Architecture. Explain architectural implication.]
* **Correction:**
    ```java
    // The fixed version of the code
    ```

---
```

### Severity definitions

| Severity | Criteria |
|----------|----------|
| **CRITICAL** | Security vulnerability, data corruption risk, blocking architectural flaw |
| **MAJOR** | SOLID violation, performance issue, significant maintainability problem |
| **MINOR** | Style issue, minor naming problem, missing optimization |

---

## Phase 4: Verification

1. **Silence on Success:** If a file adheres to all rules, output: `✅ [Filename]: No issues found.`
2. **No Fluff:** Do not output phrases like "Overall good job" or "I see you added a new DTO."
3. **Actionable Negatives Only:** Only output problems with solutions.

---

## Phase 5: Output

### Extract issue key

1. Get branch name:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
2. Extract Jira key pattern (e.g., `ABC-1234`) from branch name.
3. **IF no key found:** Ask user to provide issue key.

### Create output file

```
<workspace_root>/ai/<issue-key>/review/review-<YYYY-MM-DD-HHmm>.md
```

Example: `ai/EIN-1588/review/review-2026-01-29-0200.md`

---

## Phase 6: Action Triggers

After listing all issues, end with:

```
I have identified [X] issues ([Y] CRITICAL, [Z] MAJOR, [W] MINOR).

Would you like me to:
1. Apply the CRITICAL fixes automatically?
2. Generate Unit Tests for these changes?
3. Show detailed architectural implications?
```

---

## Quick reference

### Common commands

| Action | Command |
|--------|---------|
| Staged changes | `git diff --staged` |
| File names only | `git diff --staged --name-only` |
| Specific file | `git diff <path>` |
| Branch name | `git rev-parse --abbrev-ref HEAD` |

### Severity quick guide

| Find | Severity |
|------|----------|
| `@Autowired` on field | CRITICAL |
| `import static` | MAJOR |
| `catch (Exception e)` | MAJOR |
| Empty catch block | CRITICAL |
| Magic number | MINOR |
| Missing `final` | MINOR |

---

## Tone & Style

- **Radical Candor.** No fluff. No pleasantries. Go straight to flaws.
- **Strict Technical Lead.** Do not use "Great job" or "Nice start."
- **Teach on CRITICAL.** Explain architectural implications for every critical issue.
- Follow `Rules for Agent` (Strict Architect Persona).
