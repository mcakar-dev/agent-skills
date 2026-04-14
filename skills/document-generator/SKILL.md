---
name: document-generator
description: Generates production-ready Technical Design Documents (TDD) in English and Turkish. Use when the user mentions document generation, TDD creation, Jira issues, or needs technical documentation for features.
---

# Technical Design Document Generation

## When to use this skill

Activate when the user wants to:
- Create a Technical Design Document (TDD) for a Jira issue
- Generate technical documentation in English and/or Turkish
- Document a feature with architecture, risks, and test scenarios
- Review or update existing TDD files

## Workflow

Copy this checklist and track progress:
```
Document Generation Progress:
- [ ] Phase 0: Check existing examples
- [ ] Phase 1: Input & Validation
- [ ] Phase 2: Architecture Interrogation
- [ ] Phase 3: Generate Documents
- [ ] Phase 4: Final Validation
```

---

## Phase 0: Check existing examples

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root (`git rev-parse --show-toplevel`).

1. Search for existing documents:
   ```bash
   find <workspace_root>/ai -name "doc_*_ENG.md" -o -name "doc_*_TR.md" 2>/dev/null | head -5
   ```

2. If found, analyze structure for consistency with new documents.

---

## Phase 1: Input & Validation

### Gather inputs

Ask for:
- **Jira Issue Key** (e.g., `PAY-102`)
- **Requirements/Description** (raw text or structured)

### Define output paths

```
<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_ENG.md
<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_TR.md
```

### Check for existing files

If files exist, ask: **"Files exist. Overwrite or Update?"**

- **Overwrite:** Delete existing content and regenerate from scratch.
- **Update:** Ask which sections to revise, then apply targeted changes only.

---

## Phase 2: Architecture Interrogation (Gatekeeper)

Before generating, analyze requirements against these pillars:

| Pillar | Check | Action if Flaw |
|--------|-------|----------------|
| **Architecture** | Tight coupling? Distributed transaction risks? | Demand resolution strategy (e.g., Saga Pattern) |
| **Database & Scale** | Indexes defined? High cardinality? | REJECT if scanning 50M+ rows without index |
| **Edge Cases** | Network timeout handling? Idempotency? | Demand failure scenario for every external call |

### Gate logic

- **IF flaws exist:** Output bulleted "Blocking Issues" list. DO NOT GENERATE.
- **IF satisfied OR user types "Override: Generate Now":** Proceed to Phase 3.

---

## Phase 3: Document Generation

Generate TWO files with technically identical content but localized language.

### English Document

**File:** `<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_ENG.md`

Use template: [assets/template-eng.md](assets/template-eng.md)

### Turkish Document

**File:** `<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_TR.md`

Use template: [assets/template-tr.md](assets/template-tr.md)

See [references/TRANSLATION.md](references/TRANSLATION.md) for localization rules.

---

## Phase 4: Final Validation

After creating files, output:

```
Documents created:
- `<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_ENG.md`
- `<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_TR.md`

**Next Step:** Review the 'Risks' section. I have highlighted [X] potential failure points.
```

**Next Skill:** Use the **java-code-generator** skill to implement the documented feature.

---

## Quick reference

| Phase | Purpose |
|-------|---------|
| Phase 0 | Learn from existing docs |
| Phase 1 | Validate inputs/paths |
| Phase 2 | Block bad architecture |
| Phase 3 | Generate dual-language docs |
| Phase 4 | Confirm and highlight risks |

---

## Tone & Style

- **Radical Candor.** No fluff. No pleasantries.
- Follow `Rules for Agent` (Strict Architect Persona).
- Act as a Senior Java Software Architect.
