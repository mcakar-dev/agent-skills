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

## Document Writing Rules

These rules apply to **all generated documents** regardless of topic or language.

### Rule 1 — §1.1 Problem Statement: Plain Language First

- Write the problem in language any stakeholder (PM, QA, architect) can understand.
- **Do not** lead with class names, method signatures, or exception names in the main narrative.
- If technical details are necessary for implementors, isolate them in a supplementary note:
  ```
  > *Technical detail: (class/method references here, only if needed)*
  ```
- The main text must answer: *What breaks? What is the user/system impact? Why does it happen?* — without requiring code knowledge.

### Rule 2 — §3.1 Diagram: Always Required

- Always include a Mermaid sequence or flow diagram. A minimal diagram is better than none.
- The diagram **must** show the main happy-path and at least one failure or fallback path.
- Do not mark the diagram as optional. Remove any "(If needed)" qualifier.

### Rule 3 — §7 Test Scenarios: Gherkin Format with Checkboxes

- Each scenario must use Given / When / Then in plain language.
- Each scenario title must be a **list item** with a `[ ]` checkbox.
- Given / When / Then must be **indented sub-items** under the scenario title.
- Required format:
  ```
  * [ ] **Scenario N — [Short descriptive title]**
    * **Given** [precondition in plain language]
    * **When** [action]
    * **Then** [expected outcome]
  ```
- **Forbidden:** bold paragraph format (`**[ ] Scenario N**` without a leading `*`), dash bullets (`- **Given**`), and unit-test method name format (`givenX_whenY_thenZ`).

### Rule 4 — Bullet Lists: Always Use `*`, Never `-`

- All unordered list items must use `*` as the bullet marker.
- `-` is forbidden as a list marker anywhere in the document.
- This applies to all nesting levels, including Given / When / Then sub-items and inline bullet lists.
- **Reason:** Pandoc's JIRA writer merges `-`-initiated lists inconsistently with adjacent paragraphs, producing single-line output in Confluence.

### Rule 5 — Standalone Bold Labels: Always Follow With a Blank Line

- When a `**Label:**` occupies its **own line** (not inline with text), the very next line must be blank before any content follows — regardless of whether that content is a paragraph, a list, or a numbered list.
- Required format:
  ```
  **Label:**

  Content starts here.
  ```
- **Forbidden:** placing content directly on the line after a standalone label:
  ```
  **Label:**
  Content starts here.   ← WRONG
  ```
- **Reason:** Pandoc's JIRA writer collapses a standalone label and its immediately following content into a single paragraph, breaking Confluence rendering.
- Labels that are **inline** (label and content on the same line) are exempt:
  ```
  * **Inline Label:** content here   ← OK, no blank line needed
  ```

---

## Tone & Style

- **Radical Candor.** No fluff. No pleasantries.
- Follow `Rules for Agent` (Strict Architect Persona).
- Act as a Senior Java Software Architect.
