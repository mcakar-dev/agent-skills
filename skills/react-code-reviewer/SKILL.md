---
name: react-code-reviewer
description: Reviews React frontend code for Clean Code, component design, hooks correctness, performance, and security violations. Use when the user requests code review, mentions staged changes, security audit, or architecture analysis for React/TypeScript projects.
---

# React Code Review

## When to use this skill

Activate when the user wants to:
- Review staged git changes (`git diff --staged`) in a React project
- Analyze specific React components, hooks, or utilities
- Perform security or architecture audit on frontend code
- Check code against React best practices, Clean Code, and SOLID principles

**Scope:** This skill is exclusively for React frontend projects (`.tsx`, `.ts`, `.jsx`, `.js` files within React codebases). Do NOT activate for backend, Java, or non-React code.

## Workflow

Copy this checklist and track progress:
```
React Code Review Progress:
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
- **IF empty:** STOP. Output: `"No staged changes found. Please stage your changes (git add) or specify the file/component path to review."`
- **IF files found:** Proceed.

### Retrieve diff

```bash
git diff --staged
```

For specific paths:
```bash
git diff <path>
```

### Inclusion filters

Only review these patterns:
- `**/*.tsx`, `**/*.ts`
- `**/*.jsx`, `**/*.js` (in React projects)
- `**/*.css`, `**/*.module.css`, `**/*.scss` (only if directly related to a changed component)

### Exclusion filters

Ignore these patterns:
- `node_modules/`, `dist/`, `build/`, `.next/`, `out/`
- `.idea/`, `.vscode/`, `.cache/`
- `*.test.tsx`, `*.spec.tsx` (reviewed separately if requested)
- `*.snap` (Jest snapshots)
- `*.generated.ts`, `*.d.ts`

**Strict Rule:** Only review modified lines + 3 lines of context. If a 300-line component has 1 changed line, review ONLY that line and its architectural impact.

---

## Phase 2: Analysis

Evaluate every change against these criteria. See [references/CHECKLIST.md](references/CHECKLIST.md) for detailed rules.

### Priority order

| Priority | Category | Examples |
|----------|----------|----------|
| **P1** | Security | `dangerouslySetInnerHTML`, exposed secrets, insecure event handlers, XSS |
| **P2** | Architecture | SRP violations in components, prop drilling, improper hook usage |
| **P3** | Performance | Missing memoization, unnecessary re-renders, missing `key` props |
| **P4** | Clean Code | Naming, DRY, magic literals, conditional rendering, accessibility |

### React-specific checks

| Rule | Violation | Severity |
|------|-----------|----------|
| No `dangerouslySetInnerHTML` with unsanitized input | Raw user input rendered as HTML | CRITICAL |
| No exposed secrets/keys in source | `apiKey`, `secret` literals in code | CRITICAL |
| No direct state mutation | `state.items.push(...)` | CRITICAL |
| Rules of Hooks | Hooks inside conditions/loops | CRITICAL |
| Missing `key` prop in lists | `array.map(item => <Component />)` | MAJOR |
| Missing `useCallback`/`useMemo` for expensive ops | Functions recreated every render | MAJOR |
| Missing exhaustive deps in `useEffect` | ESLint `react-hooks/exhaustive-deps` | MAJOR |
| No `any` type in TypeScript | `const handler = (e: any) => ...` | MAJOR |
| Prop drilling beyond 2 levels | Passing props through 3+ components | MAJOR |
| Components larger than 200 lines | God components | MAJOR |
| Inline object/function in JSX | `<Component style={{ ... }} />` per render | MINOR |
| Missing accessibility attributes | `<img>` without `alt`, buttons without `aria-label` | MINOR |

### Anti-patterns

See [references/PATTERNS.md](references/PATTERNS.md) for common anti-patterns and fixes.

---

## Phase 3: Reporting

**Do not summarize. Do not praise.** Output strictly in this format:

Use template: [assets/review-template.md](assets/review-template.md)

### Issue block format

```markdown
**File:** `[path/to/Component.tsx]`

> **Code Under Review:**
> ```tsx
> // The specific lines from the diff that are problematic
> const MyComponent = () => { ... }
> ```

* **Severity:** `[CRITICAL / MAJOR / MINOR]`
* **Issue:** [Concise explanation of *why* this is wrong. Reference React rules/architecture. Explain the implication.]
* **Correction:**
    ```tsx
    // The fixed version of the code
    ```

---
```

### Severity definitions

| Severity | Criteria |
|----------|----------|
| **CRITICAL** | Security vulnerability, direct state mutation, Rules of Hooks violation, data corruption risk |
| **MAJOR** | Performance regression, SOLID violation, significant maintainability problem, missing types |
| **MINOR** | Style issue, missing accessibility attribute, inline object in JSX, naming inconsistency |

---

## Phase 4: Verification

1. **Silence on Success:** If a file adheres to all rules, output: `✅ [Filename]: No issues found.`
2. **No Fluff:** Do not output phrases like "Overall good job" or "I see you added a new component."
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

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root (`git rev-parse --show-toplevel`).

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
2. Generate unit/integration tests for these changes?
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
| `dangerouslySetInnerHTML` with user input | CRITICAL |
| `state.x.push(...)` direct mutation | CRITICAL |
| Hook inside `if`/`for` | CRITICAL |
| `any` TypeScript type | MAJOR |
| Missing `key` in list | MAJOR |
| Missing `useEffect` dependency | MAJOR |
| Component > 200 lines | MAJOR |
| `<img>` missing `alt` | MINOR |
| Inline `style={{ }}` in JSX | MINOR |
