# Commit Message Template

## Format

```
<TYPE>[SCOPE]: <DESCRIPTION>

<BODY>

Refs: <ISSUE_KEY>
<ADDITIONAL_FOOTER>
```

## Placeholders

| Placeholder | Description | Required |
|-------------|-------------|----------|
| `<TYPE>` | Commit type (feat, fix, docs, etc.) | Yes |
| `[SCOPE]` | Affected component/module in parentheses | No |
| `<DESCRIPTION>` | Short summary in imperative mood | Yes |
| `<BODY>` | Detailed explanation (what and why) | No |
| `<ISSUE_KEY>` | Jira/GitHub issue key (extracted from branch or user input) | **Yes** |
| `<ADDITIONAL_FOOTER>` | Breaking changes, co-authors, etc. | No |

---

## Type Options

```
feat     - New feature
fix      - Bug fix
docs     - Documentation only
style    - Formatting, no code change
refactor - Code restructure, no behavior change
perf     - Performance improvement
test     - Adding/updating tests
build    - Build system, dependencies
ci       - CI/CD configuration
chore    - Maintenance tasks
revert   - Reverting previous commit
```

---

## Fill-in Templates

### Simple (type + description + issue)
```
<TYPE>: <DESCRIPTION>

Refs: <ISSUE_KEY>
```
Example:
```
fix: resolve null pointer in user service

Refs: ABC-1234
```

### With scope
```
<TYPE>(<SCOPE>): <DESCRIPTION>
```
Example: `feat(auth): add OAuth2 support`

### With body
```
<TYPE>(<SCOPE>): <DESCRIPTION>

<WHY_THIS_CHANGE>
<WHAT_WAS_DONE>

Refs: <ISSUE_KEY>
```

### With breaking change (! notation)
```
<TYPE>(<SCOPE>)!: <DESCRIPTION>

BREAKING CHANGE: <BREAKING_DESCRIPTION>

Refs: <ISSUE_KEY>
```

### With breaking change (footer)
```
<TYPE>(<SCOPE>): <DESCRIPTION>

<BODY>

BREAKING CHANGE: <BREAKING_DESCRIPTION>
Refs: <ISSUE_KEY>
```

### With multiple footers
```
<TYPE>(<SCOPE>): <DESCRIPTION>

<BODY>

Refs: <ISSUE_KEY>
Closes: #<ISSUE_NUMBER>
```

---

## Description Guidelines

- Start with lowercase
- Use imperative mood ("add" not "added" or "adds")
- No period at the end
- Max 72 characters
- Be specific and concise

**Good:** `add user authentication endpoint`
**Bad:** `Added new endpoint for users to authenticate.`
