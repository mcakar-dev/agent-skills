---
name: eng-to-tr-translator
description: Translates English text to Turkish while preserving technical terms in English. Use when the user wants to translate documentation, messages, user stories, or any text from English to Turkish.
---

# English to Turkish Translator

## When to use this skill

Activate when the user wants to:
- Translate English text (documentation, messages, comments, user stories) to Turkish
- Convert English technical documents to Turkish while keeping technical vocabulary intact
- Review or improve existing English-to-Turkish translations
- Verify that technical terms were not incorrectly translated

## Core Rule

**Keep globally recognized technical terms in English.** Translate headers and body text to Turkish, but preserve technical vocabulary exactly as listed in [references/TECHNICAL_TERMS.md](references/TECHNICAL_TERMS.md).

---

## Workflow

Copy this checklist and track progress:
```
Translation Progress:
- [ ] Phase 1: Input Validation
- [ ] Phase 2: Technical Term Scan
- [ ] Phase 3: Translation
- [ ] Phase 4: Post-Translation Validation
- [ ] Phase 5: Output
```

---

## Phase 1: Input Validation

1. Accept input as one of:
   - Raw English text (pasted or typed)
   - File path to an English `.md`, `.txt`, or other text file
   - Clipboard content

2. Validate the input is in English. If mixed or unclear, ask: **"Is this text fully in English?"**

3. If an output file path is specified, confirm the path before proceeding.

---

## Phase 2: Technical Term Scan

1. Load the protected terms dictionary from [references/TECHNICAL_TERMS.md](references/TECHNICAL_TERMS.md).

2. Scan the input text and **tag every occurrence** of a protected technical term.

3. These tagged terms must **not** be translated in Phase 3.

4. If a term looks technical but is **not** in the dictionary, flag it:
   ```
   Unrecognized term: "<term>". Keep in English or translate?
   ```

5. **Count tagged terms.** Maintain a running total of all protected term occurrences. This count is reported in the Phase 5 output summary.

---

## Phase 3: Translation

Apply these rules strictly:

### What to translate
- Headers and section titles
- Body text, descriptions, and explanations
- Bullet point content (non-technical parts)
- Table cell content (non-technical parts)

### What NOT to translate
- Terms listed in [references/TECHNICAL_TERMS.md](references/TECHNICAL_TERMS.md)
- Code blocks, variable names, file paths
- Proper nouns (product names, company names)
- Acronyms (JWT, SSL, API, REST, SOAP, etc.)

### Grammar and style rules

Follow [references/GRAMMAR_RULES.md](references/GRAMMAR_RULES.md) for:
- Turkish suffix harmony when appending to English terms
- SOV sentence structure
- Formal register (`siz` form)
- Apostrophe usage for suffixes on English words

---

## Phase 4: Post-Translation Validation

Run these checks on the translated output:

| Check | Action if Failed |
|-------|-----------------|
| Any protected term translated? | Revert to English form |
| Turkish suffix harmony correct? | Fix vowel/consonant harmony |
| Sentence structure natural? | Restructure to SOV if needed |
| Code blocks untouched? | Restore original code blocks |
| Consistent terminology? | Align all occurrences |

---

## Phase 5: Output

1. Present the translated text to the user.

2. If an output file path was specified, write the result to file.

3. Summary:
   ```
   Translation complete.
   - Input: [source description]
   - Output: [target description]
   - Protected terms preserved: [count]
   - Flagged terms: [count, if any]
   ```

---

## Quick Reference

| Phase | Purpose |
|-------|---------|
| Phase 1 | Validate input text |
| Phase 2 | Identify and protect technical terms |
| Phase 3 | Translate to Turkish |
| Phase 4 | Verify translation quality |
| Phase 5 | Deliver output |

---

## Examples

### Input (English)
```
The deploy pipeline failed. Create a merge request with the bugfix 
and push it to the feature branch. Set the timeout to 5000ms and 
add a retry mechanism for the endpoint.
```

### Output (Turkish)
```
Deploy Pipeline başarısız oldu. Bugfix ile bir Merge Request oluşturun
ve Feature branch'e Push edin. Endpoint için Timeout'u 5000ms olarak
ayarlayın ve bir Retry mekanizması ekleyin.
```

### Bad Translation (What to avoid)
```
Dağıtım boru hattı başarısız oldu. Hata düzeltme ile bir birleştirme
isteği oluşturun ve özellik dalına itin.
```

---

## Tone & Style

- Formal register. Use `siz` form for professional documentation.
- Radical Candor. No fluff.
- When in doubt about a term, keep it in English.
