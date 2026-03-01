# Blog Post Review Report

**Date:** {{DATE}}
**Article:** {{ARTICLE_TITLE}}
**Reviewer:** AI Blog Post Review Agent

---

## Summary

| Category | Count |
|----------|-------|
| 🔴 CRITICAL Code Issues | {{CRITICAL_COUNT}} |
| 🟠 MAJOR Code Issues | {{MAJOR_COUNT}} |
| 🟡 MINOR Code Issues | {{MINOR_COUNT}} |
| 📝 Conceptual Issues | {{CONCEPTUAL_COUNT}} |
| 📖 Clarity Issues | {{CLARITY_COUNT}} |

---

## 1. Code Audit

{{#CODE_ISSUES}}

**Snippet:** `{{SNIPPET_CONTEXT}}`

> **Code Under Review:**
> ```{{LANGUAGE}}
> {{CODE_SNIPPET}}
> ```

* **Severity:** `{{SEVERITY}}`
* **Principle:** `{{PRINCIPLE}}`
* **The Issue:** {{ISSUE_DESCRIPTION}}
* **Refactored Solution:**
    ```{{LANGUAGE}}
    {{CORRECTED_CODE}}
    ```

---

{{/CODE_ISSUES}}

{{#NO_CODE_ISSUES}}
✅ All code snippets pass review.
{{/NO_CODE_ISSUES}}

## 2. Conceptual Review

{{#CONCEPTUAL_ISSUES}}

**Accuracy Issue:** {{CLAIM}}
* **Type:** `{{ISSUE_TYPE}}`
* **The Issue:** {{ISSUE_DESCRIPTION}}
* **Correction:** {{CORRECTION}}

---

{{/CONCEPTUAL_ISSUES}}

{{#NO_CONCEPTUAL_ISSUES}}
✅ All technical claims verified.
{{/NO_CONCEPTUAL_ISSUES}}

## 3. Tone & Clarity

{{#CLARITY_ISSUES}}

**Clarity Issue:** {{SECTION_REFERENCE}}
* **Type:** `{{ISSUE_TYPE}}`
* **The Issue:** {{ISSUE_DESCRIPTION}}
* **Suggestion:** {{SUGGESTION}}

---

{{/CLARITY_ISSUES}}

{{#NO_CLARITY_ISSUES}}
✅ Article structure and clarity are acceptable.
{{/NO_CLARITY_ISSUES}}

## 4. Final Verdict

* **Status:** `{{VERDICT}}`
* **Action:** {{ACTION_SUMMARY}}

---

## Next Steps

I have identified {{TOTAL_CODE_ISSUES}} code issues ({{CRITICAL_COUNT}} CRITICAL, {{MAJOR_COUNT}} MAJOR, {{MINOR_COUNT}} MINOR) and {{CONCEPTUAL_COUNT}} conceptual issues.

Would you like me to:
1. Generate a corrected version of all code snippets?
2. Rewrite problematic sections with accurate explanations?
3. Show detailed architectural implications for CRITICAL issues?
