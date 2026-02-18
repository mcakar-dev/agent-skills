# Code Review Report

**Date:** {{DATE}}  
**Branch:** {{BRANCH}}  
**Issue:** {{ISSUE_KEY}}  
**Reviewer:** AI Code Review Agent

---

## Summary

| Severity | Count |
|----------|-------|
| 🔴 CRITICAL | {{CRITICAL_COUNT}} |
| 🟠 MAJOR | {{MAJOR_COUNT}} |
| 🟡 MINOR | {{MINOR_COUNT}} |

---

## Issues

{{#ISSUES}}

### {{FILE_PATH}}

> **Code Under Review:**
> ```java
> {{CODE_SNIPPET}}
> ```

* **Severity:** `{{SEVERITY}}`
* **Issue:** {{ISSUE_DESCRIPTION}}
* **Correction:**
    ```java
    {{CORRECTED_CODE}}
    ```

---

{{/ISSUES}}

{{#NO_ISSUES}}
✅ **{{FILE_PATH}}**: No issues found.
{{/NO_ISSUES}}

---

## Next Steps

I have identified {{TOTAL_ISSUES}} issues ({{CRITICAL_COUNT}} CRITICAL, {{MAJOR_COUNT}} MAJOR, {{MINOR_COUNT}} MINOR).

Would you like me to:
1. Apply the CRITICAL fixes automatically?
2. Generate Unit Tests for these changes?
3. Show detailed architectural implications?
