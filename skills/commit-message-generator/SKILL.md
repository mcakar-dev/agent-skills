---
name: commit-message-generator
description: Generates conventional commit messages by analyzing staged git changes. Use when the user asks to generate a commit message, wants to commit changes, or mentions conventional commits.
---

# Commit Message Generator

## When to use this skill

Activate when the user wants to:
- Generate a commit message for staged changes
- Follow Conventional Commits specification
- Create semantic commit messages
- Prepare a commit with proper type and scope

## Workflow

Copy this checklist and track progress:
```
Commit Message Generation Progress:
- [ ] Phase 0: Issue Key Extraction
- [ ] Phase 1: Scope Extraction
- [ ] Phase 2: Change Analysis
- [ ] Phase 3: Clarification (if needed)
- [ ] Phase 4: Message Generation
- [ ] Phase 5: User Confirmation
```

---

## Phase 0: Issue Key Extraction

### Get branch name

```bash
git rev-parse --abbrev-ref HEAD
```

### Extract issue key

Search for patterns:
- **Jira:** `[A-Z]+-[0-9]+` (e.g., `ABC-1234`, `EIN-567`)
- **GitHub:** `#[0-9]+` or `issue-[0-9]+` (e.g., `#123`, `issue-456`)

**Common branch patterns:**
```
feature/MC/master/ABC-1234
bugfix/EIN-567
bugfix/123-fix-validation
ABC-1234_some_description
```

**Decision tree:**
- **IF key found:** Store for use in commit footer.
- **IF no key found:** Ask user:
  ```
  No issue key found in branch name.
  Please provide the Jira/GitHub issue key (e.g., ABC-1234 or #123):
  ```

---

## Phase 1: Scope Extraction

### Fetch staged changes

```bash
git diff --staged --name-only
```

**Decision tree:**
- **IF empty:** STOP. Output: `"No staged changes found. Stage your changes with 'git add' first."`
- **IF files found:** Get full diff.

```bash
git diff --staged
```

### Exclusion filters

Ignore these patterns:
- `target/`, `build/`, `.gradle/`, `node_modules/`, `dist/`
- `.idea/`, `.vscode/`, `.settings/`
- `*.generated.java`, `*_.java` (MapStruct)
- `package-lock.json`, `yarn.lock`

---

## Phase 2: Change Analysis

Analyze the diff to determine:

| Factor | How to detect |
|--------|---------------|
| **Type** | New files = `feat`, Bug fixes = `fix`, Tests = `test`, Docs = `docs` |
| **Scope** | Most changed module/package/component |
| **Breaking** | Method signature changes, removed public APIs, renamed classes |
| **Complexity** | Single-purpose change vs multiple concerns |

### Type detection rules

| Pattern | Type |
|---------|------|
| New feature/functionality | `feat` |
| Bug fix, error correction | `fix` |
| Documentation only | `docs` |
| Formatting, whitespace | `style` |
| Code restructure (no behavior change) | `refactor` |
| Performance improvement | `perf` |
| Adding/modifying tests | `test` |
| Build system, dependencies | `build` |
| CI/CD configuration | `ci` |
| Maintenance, chores | `chore` |
| Reverting previous commit | `revert` |

---

## Phase 3: Clarification

> **STRICT RULE:** Do NOT guess. If any of the following is unclear, ask the user directly.

Ask user when:
- [ ] Type is ambiguous (e.g., fix + refactor in same change)
- [ ] Scope is unclear (multiple components affected equally)
- [ ] Cannot determine if change is breaking
- [ ] Business context is needed for description
- [ ] Multiple unrelated changes detected (suggest splitting)

**Clarification format:**
```
I need clarification to generate an accurate commit message:

1. [Question about type/scope/breaking change]
2. [Question about business context if needed]

Changes detected:
- [file1]: [brief change description]
- [file2]: [brief change description]
```

---

## Phase 4: Message Generation

Use template: [assets/commit-template.md](assets/commit-template.md)

### Message format

```
<type>[optional scope]: <description>

[optional body]

Refs: <ISSUE_KEY>
[optional additional footer(s)]
```

### Rules

1. **Type:** Lowercase noun from type list
2. **Scope:** Optional, in parentheses: `feat(parser):`
3. **Description:** Imperative mood, lowercase start, no period at end
4. **Body:** Blank line after description, explain *what* and *why*
5. **Issue Ref:** Always include `Refs: <ISSUE_KEY>` from Phase 0
6. **Footer:** `BREAKING CHANGE:`, `Closes:`, etc.

### Breaking changes

Two options:
```
feat!: remove deprecated endpoint
```
OR
```
feat: update authentication flow

BREAKING CHANGE: JWT tokens now expire after 1 hour instead of 24 hours.
```

### SemVer correlation

| Type | SemVer Impact |
|------|---------------|
| `fix` | PATCH |
| `feat` | MINOR |
| `BREAKING CHANGE` / `!` | MAJOR |

---

## Phase 5: User Confirmation

Present generated message:

```
📝 Generated Commit Message:

---
<generated message here>
---

Options:
1. ✅ Use this message (I will run `git commit`)
2. ✏️ Edit (provide your changes)
3. 🔄 Regenerate with different type/scope
```

**On approval:** Run `git commit -m "<message>"` (or with `-m` for body if present)

---

## Quick reference

### Common commands

| Action | Command |
|--------|---------|
| Staged changes | `git diff --staged` |
| File names only | `git diff --staged --name-only` |
| Commit with message | `git commit -m "<message>"` |
| Multi-line commit | `git commit -m "<title>" -m "<body>"` |

### Type cheat sheet

| When you... | Use |
|-------------|-----|
| Add new functionality | `feat` |
| Fix a bug | `fix` |
| Update docs | `docs` |
| Refactor without behavior change | `refactor` |
| Add/update tests | `test` |
| Update build/deps | `build` |

---

## Examples

### Simple feature
```
feat(auth): add password reset endpoint
```

### Bug fix with scope
```
fix(parser): handle empty arrays correctly
```

### Breaking change with body
```
feat(api)!: change response format for user endpoint

BREAKING CHANGE: Response now returns `data` wrapper object.
Old clients expecting direct array will break.

Refs: #123
```

### Multi-file change with body
```
refactor(service): extract validation logic to separate class

Move input validation from UserService to UserValidator.
This improves testability and follows SRP.
```
