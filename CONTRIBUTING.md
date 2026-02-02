# Contributing to Agent Skills

## Adding a New Skill

### 1. Create Skill Directory

```bash
mkdir -p skills/your-skill-name
```

### 2. Naming Conventions

| Rule | Example |
|------|---------|
| Lowercase only | `data-analysis` ✓ |
| Hyphens for spaces | `code-review` ✓ |
| Gerund form preferred | `pdf-processing` ✓ |
| Max 64 characters | Keep it concise |

### 3. Required Structure

```
skills/your-skill-name/
├── SKILL.md              # Required: main instructions
├── references/           # Optional: detailed docs
│   └── REFERENCE.md
└── assets/               # Optional: templates
    └── template.md
```

### 4. SKILL.md Template

```yaml
---
name: your-skill-name
description: Brief description of what it does. Use when [triggers].
---

# Skill Title

## When to use this skill

Describe activation triggers.

## Workflow

Step-by-step process.

## Examples

Concrete examples of usage.
```

### 5. Validation Checklist

Before submitting:

- [ ] `name` in frontmatter matches directory name
- [ ] `description` explains what AND when to trigger
- [ ] SKILL.md is under 500 lines
- [ ] Examples are concrete and tested
- [ ] No hardcoded absolute paths

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b skill/your-skill-name`
3. Add your skill under `skills/`
4. Test locally with the install script
5. Submit a pull request

## Testing Locally

```bash
# Install your skill to test
./scripts/install-skills.sh --ide antigravity --skills your-skill-name --dry-run

# If dry-run looks good, install
./scripts/install-skills.sh --ide antigravity --skills your-skill-name
```

## Code of Conduct

Be respectful. Focus on quality over quantity.
