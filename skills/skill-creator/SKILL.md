---
name: skill-creator
description: Creates new Agent Skills for agentic IDEs following the open specification. Use when the user wants to create a new skill, scaffold a skill directory, write SKILL.md files, or needs guidance on skill authoring best practices.
---

# Creating Agent Skills

## When to use this skill

Activate when the user wants to:
- Create a new skill from scratch
- Scaffold a skill directory structure
- Write or improve SKILL.md files
- Add scripts, references, or assets to existing skills
- Validate skill structure and naming conventions

## Skill creation workflow

Copy this checklist and track progress:
```
Skill Creation Progress:
- [ ] Step 1: Gather requirements
- [ ] Step 2: Define name and description
- [ ] Step 3: Create directory structure
- [ ] Step 4: Write SKILL.md content
- [ ] Step 5: Add supporting files (if needed)
- [ ] Step 6: Validate and review
```

---

## Step 1: Gather requirements

Ask the user:
1. **What problem does this skill solve?**
2. **What triggers should activate this skill?** (keywords, file types, actions)
3. **What outputs or artifacts should it produce?**
4. **Does it need scripts, templates, or reference docs?**

---

## Step 2: Define name and description

### Naming rules

| Rule | Example |
|------|---------|
| Lowercase only | `data-analysis` or `document-generator` ✓ |
| Hyphens for spaces | `code-review` ✓ |
| Gerund form preferred | `pdf-processing` ✓ |
| Max 64 characters | Keep it concise |
| No consecutive hyphens | `skill--name` ✗ |
| No leading/trailing hyphens | `-skill` ✗ |

### Description template

```yaml
description: [Action verb] [what it does]. Use when [specific triggers/contexts].
```

**Examples:**
```yaml
description: Generates unit tests for Java code following TDD practices. Use when the user asks for tests, mentions coverage, or works with test files.

description: Reviews code for security vulnerabilities and best practices. Use when the user requests code review, security audit, or mentions OWASP.
```

---

## Step 3: Create directory structure

### Minimal structure
```
skill-name/
└── SKILL.md
```

### Standard structure (recommended)
```
skill-name/
├── SKILL.md              # Required: main instructions
├── references/           # Optional: detailed docs
│   ├── REFERENCE.md
│   └── EXAMPLES.md
└── assets/               # Optional: templates
    └── template.md
```

### Full structure (for complex skills)
```
skill-name/
├── SKILL.md
├── references/
│   ├── REFERENCE.md
│   ├── EXAMPLES.md
│   └── domain-specific.md
├── scripts/
│   ├── helper.py
│   └── validate.sh
└── assets/
    ├── template.md
    └── config.json
```

Create with:
```bash
mkdir -p skill-name/{references,scripts,assets}
touch skill-name/SKILL.md
```

---

## Step 4: Write SKILL.md content

### Required frontmatter
```yaml
---
name: skill-name
description: Detailed description of what and when.
---
```

### Optional frontmatter fields
```yaml
---
name: skill-name
description: Description here.
license: Apache-2.0
compatibility: Requires Python 3.9+, git
metadata:
  author: team-name
  version: "1.0"
---
```

### Body structure template

See [templates/skill-template.md](assets/skill-template.md) for full template.

Key sections:
1. **When to use** - Activation triggers
2. **Workflow** - Step-by-step process with checklist
3. **Quick reference** - Common commands/patterns
4. **Examples** - Input/output demonstrations
5. **Advanced features** - Links to reference docs

### Writing guidelines

| Do | Don't |
|-----|-------|
| Be concise (~500 lines max) | Over-explain basics |
| Use code examples | Describe what code does |
| Provide defaults | Offer many options |
| Use forward slashes in paths | Use Windows-style paths |
| Write in third person | Use "I" or "you" in description |

---

## Step 5: Add supporting files

### Reference files (`references/`)

For detailed documentation loaded on-demand:
- `REFERENCE.md` - API/technical reference
- `EXAMPLES.md` - Usage examples
- Domain-specific files (e.g., `security.md`, `patterns.md`)

### Scripts (`scripts/`)

For executable utilities:
```python
#!/usr/bin/env python3
"""Script description.

Usage:
    python scripts/helper.py <input> <output>
"""

import sys

def main():
    # Handle errors explicitly, don't punt to agent
    try:
        # implementation
        pass
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### Assets (`assets/`)

For templates and static resources:
- Output templates
- Configuration schemas
- Example files

---

## Step 6: Validate and review

### Validation checklist

**Frontmatter:**
- [ ] `name` matches directory name
- [ ] `name` is lowercase with hyphens only
- [ ] `description` explains what AND when
- [ ] `description` uses third person

**Content:**
- [ ] SKILL.md under 500 lines
- [ ] Workflow has clear steps
- [ ] Examples are concrete
- [ ] No time-sensitive information
- [ ] File references one level deep

**Scripts (if applicable):**
- [ ] Error handling is explicit
- [ ] No magic numbers
- [ ] Dependencies documented
- [ ] Forward slashes in paths

---

## Quick reference: YAML frontmatter

```yaml
---
name: my-skill-name          # Required: lowercase, hyphens, max 64 chars
description: What it does.   # Required: max 1024 chars, what + when
license: Apache-2.0          # Optional: license info
compatibility: Python 3.9+   # Optional: environment requirements
metadata:                    # Optional: key-value pairs
  author: team
  version: "1.0"
---
```

---

## Examples

### Example 1: Simple skill

```yaml
---
name: formatting-markdown
description: Formats and lints Markdown files. Use when the user mentions 
  markdown formatting, linting .md files, or asks to clean up documentation.
---

# Formatting Markdown

## Quick start

Format a file:
```bash
npx prettier --write "**/*.md"
```

Lint for issues:
```bash
npx markdownlint "**/*.md"
```

## Common fixes

| Issue | Fix |
|-------|-----|
| Inconsistent headings | Use ATX style (`#`) |
| Long lines | Wrap at 80 characters |
| Missing blank lines | Add before/after headings |
```

### Example 2: Skill with workflow

See [references/EXAMPLES.md](references/EXAMPLES.md) for complex examples including:
- Skills with scripts
- Multi-domain skills
- Skills with templates

---

## Anti-patterns to avoid

| Anti-pattern | Why it's bad | Fix |
|--------------|--------------|-----|
| Vague description | Poor discovery | Include triggers |
| Too many options | Confuses agent | Provide defaults |
| Over-explaining | Wastes tokens | Be concise |
| Deep file nesting | Hard to navigate | One level deep |
| Windows paths | Cross-platform issues | Use `/` always |
