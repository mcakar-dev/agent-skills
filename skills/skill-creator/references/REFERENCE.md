# Agent Skills Specification Reference

Technical reference for the Agent Skills format.

---

## YAML Frontmatter Fields

### Required Fields

| Field | Type | Constraints |
|-------|------|-------------|
| `name` | string | 1-64 chars, lowercase alphanumeric + hyphens, no `--`, no leading/trailing `-` |
| `description` | string | 1-1024 chars, non-empty, describes what + when |

### Optional Fields

| Field | Type | Constraints |
|-------|------|-------------|
| `license` | string | License name or file reference |
| `compatibility` | string | 1-500 chars, environment requirements |
| `metadata` | map | Key-value pairs for custom properties |
| `allowed-tools` | string | Space-delimited tool list (experimental) |

---

## Name Validation Rules

```
Valid:
  ^[a-z0-9]+(-[a-z0-9]+)*$
  
  ✓ pdf-processing
  ✓ code-review
  ✓ analyzing-data-v2
  ✓ my123skill
  
Invalid:
  ✗ PDF-Processing     (uppercase)
  ✗ -pdf               (leading hyphen)
  ✗ pdf-               (trailing hyphen)
  ✗ pdf--processing    (consecutive hyphens)
  ✗ my skill           (space)
  ✗ my_skill           (underscore)
```

---

## Directory Structure

### Required
```
skill-name/
└── SKILL.md          # Must exist, must have valid frontmatter
```

### Optional Directories

| Directory | Purpose | Loading |
|-----------|---------|---------|
| `scripts/` | Executable code | Executed on-demand |
| `references/` | Documentation | Read on-demand |
| `assets/` | Templates, resources | Read on-demand |

---

## Token Budget Guidelines

| Component | Budget | Notes |
|-----------|--------|-------|
| Metadata | ~100 tokens | Loaded at startup for all skills |
| SKILL.md body | <5000 tokens | Loaded when skill activates |
| Reference files | Variable | Loaded only when referenced |

**Recommendation:** Keep SKILL.md under 500 lines.

---

## File Reference Syntax

Use relative paths from skill root:

```markdown
See [FORMS.md](references/FORMS.md) for details.
Run: python scripts/helper.py
```

**Rules:**
- One level deep maximum
- Always use forward slashes
- Reference files by relative path

---

## Progressive Disclosure Levels

```
Level 1: Discovery (startup)
├── name
└── description

Level 2: Activation (skill triggered)
└── Full SKILL.md body

Level 3: Execution (as needed)
├── references/*.md
├── scripts/*.py
└── assets/*
```

---

## Reserved Words

Cannot use in `name` field:
- `anthropic`
- `claude`

---

## Validation

Validate with skills-ref library:
```bash
skills-ref validate ./my-skill
```

Checks:
- Frontmatter syntax
- Name constraints
- Description presence
- Directory name match

---

## External References

- [Agent Skills Specification](https://agentskills.io/specification)
- [Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [GitHub Examples](https://github.com/anthropics/skills)
- [Validation Library](https://github.com/agentskills/agentskills/tree/main/skills-ref)
