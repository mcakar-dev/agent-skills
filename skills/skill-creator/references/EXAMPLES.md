# Skill Examples

Reference examples for creating different types of skills.

---

## Example 1: Code Review Skill

A skill with workflow and categorized output.

```yaml
---
name: reviewing-code
description: Performs automated code review for security, performance, and 
  maintainability. Use when the user asks for code review, wants to review 
  staged changes, or needs feedback on code quality.
---

# Code Review

## Workflow

```
Review Progress:
- [ ] Step 1: Get changes (git diff --cached)
- [ ] Step 2: Analyze structure
- [ ] Step 3: Check for bugs
- [ ] Step 4: Review security
- [ ] Step 5: Generate report
```

## Issue categories

- `[CRITICAL]` - Must fix before merge
- `[MAJOR]` - Should fix
- `[MINOR]` - Nice to have

## Review focus areas

1. **Security**: SQL injection, XSS, secrets
2. **Performance**: N+1 queries, complexity
3. **Maintainability**: SOLID, clean code
```

---

## Example 2: Skill with Scripts

A skill using utility scripts for complex operations.

**Directory structure:**
```
pdf-processing/
├── SKILL.md
├── scripts/
│   ├── extract_text.py
│   ├── fill_form.py
│   └── validate.py
└── references/
    └── FORMS.md
```

**SKILL.md:**
```yaml
---
name: processing-pdfs
description: Extract text and tables from PDFs, fill forms, merge documents. 
  Use when working with PDF files or when the user mentions PDFs.
---

# PDF Processing

## Quick start

Extract text:
```bash
python scripts/extract_text.py input.pdf output.txt
```

## Form filling workflow

```
- [ ] Step 1: Analyze form (scripts/extract_fields.py)
- [ ] Step 2: Create field mapping
- [ ] Step 3: Fill form (scripts/fill_form.py)
- [ ] Step 4: Validate (scripts/validate.py)
```

For form details, see [references/FORMS.md](references/FORMS.md).

---

## Example 3: Domain-Specific Skill

A skill with multiple domain reference files.

**Directory structure:**
```
analyzing-data/
├── SKILL.md
└── references/
    ├── finance.md
    ├── sales.md
    └── marketing.md
```

**SKILL.md:**
```yaml
---
name: analyzing-data
description: Analyze business data across finance, sales, and marketing domains. 
  Use when the user asks about metrics, reports, or data analysis.
---

# Data Analysis

## Available domains

| Domain | Reference |
|--------|-----------|
| Finance | [references/finance.md](references/finance.md) |
| Sales | [references/sales.md](references/sales.md) |
| Marketing | [references/marketing.md](references/marketing.md) |

## Quick search

```bash
grep -i "revenue" references/finance.md
grep -i "pipeline" references/sales.md
```

---

## Example 4: Template-Based Skill

A skill that produces structured output.

```yaml
---
name: generating-reports
description: Generates structured reports in markdown format. Use when the 
  user needs a report, summary, or structured documentation.
---

# Report Generation

## Report template

ALWAYS use this structure:

```markdown
# [Report Title]

## Executive Summary
[One paragraph overview]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Recommendations
1. Action item 1
2. Action item 2

## Appendix
[Supporting data]
```

## Examples

**Input:** Analyze Q4 sales performance
**Output:**
```markdown
# Q4 Sales Performance Report

## Executive Summary
Q4 showed 15% growth over Q3 with strong performance in 
enterprise segment.

## Key Findings
- Enterprise deals up 25%
- SMB flat compared to Q3
- New customer acquisition down 5%

## Recommendations
1. Increase SMB marketing spend
2. Launch enterprise referral program
```

---

## Example 5: Skill with Feedback Loop

A skill with verification and iteration.

```yaml
---
name: writing-tests
description: Generates unit tests with coverage verification. Use when the 
  user asks for tests, mentions TDD, or wants to improve test coverage.
---

# Test Generation

## Workflow with verification

```
- [ ] Step 1: Analyze source code
- [ ] Step 2: Generate test cases
- [ ] Step 3: Run tests
- [ ] Step 4: Check coverage
- [ ] Step 5: Iterate if coverage < target
```

## Step 4: Check coverage

```bash
./gradlew test jacocoTestReport
```

If coverage < 80%, return to Step 2 and add tests for uncovered lines.

## Iteration loop

Repeat until:
- All tests pass
- Coverage meets target (default: 80%)
- User approves
