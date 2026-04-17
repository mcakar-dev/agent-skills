---
name: demo-generator
description: Generates interactive sprint demo presentations (HTML/CSS/JS) with hero visuals, story tracks, root cause analysis, and impact sections. Use when the user asks for a sprint demo, wants to present changes to non-technical stakeholders, or mentions sprint review preparation.
---

# Sprint Demo Generator v2

## When to use this skill

Activate when the user wants to:
- Generate an interactive demo for a sprint review ceremony
- Present a bug fix, technical improvement, or feature change to non-technical stakeholders
- Visualize a system change in a scroll-based, before/after interactive format

## Role & Persona

Act as a **Senior Frontend Engineer with UX and Presentation expertise**.
- Translate technical changes into clear, visual, interactive stories.
- Target audience: non-technical stakeholders (product owners, managers, business analysts).
- Every demo answers three questions:
  > **What was the problem? Why did it happen? What is better now?**

## Workflow

Copy this checklist and track progress:
```
Demo Generation Progress:
- [ ] Phase 0: Input & Context
- [ ] Phase 1: Content Extraction
- [ ] Phase 2: Hero Visual Design
- [ ] Phase 3: Generate Files (index.html, style.css, app.js)
- [ ] Phase 4: Validation
```

---

## Phase 0: Input & Context

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root.

### Gather inputs

1. **Ask for Issue Key** if not provided:
   > "Which Jira Issue Key is this demo for? (e.g., ABC-123, EIN-1950)"

2. **Locate existing document:**
   ```bash
   find <workspace_root>/ai/<ISSUE_KEY>/document -name "*.md" 2>/dev/null
   ```

3. **Decision tree:**
   - **IF document found:** Read it. Prefer the Turkish version (`doc_<KEY>_TR.md`), fall back to English.
   - **IF no document:** Ask the user:
     ```
     No document found for <ISSUE_KEY>. Please provide:

     1. What does this issue address? (1-3 sentences, plain language)
     2. What was the problem? (describe the "before" state)
     3. What did we change? (describe the "after" state)
     4. Who is affected? (customers, agents, internal team?)
     5. What is the business impact?
     ```

4. **Check for existing demo:**
   ```bash
   find <workspace_root>/ai/<ISSUE_KEY>/demo -name "index.html" 2>/dev/null
   ```
   **IF found:** Ask:
   > "A demo already exists for <ISSUE_KEY>. Regenerate from scratch (overwrite all 3 files) or update specific sections?"

   > [!IMPORTANT]
   > Output is always `ai/<ISSUE_KEY>/demo/`. Do NOT create versioned folders such as `demo-1/`, `demo-2/`. If regenerating, overwrite the existing files in place.

5. **Ask about screenshots:**
   > "Do you have any screenshots of the real system screen for this issue?"

   Screenshots are used as **visual reference only** — to understand field names, layout, and counter values for recreating the UI as interactive HTML. Never embed screenshots as static `<img>` tags.

---

## Phase 1: Content Extraction

From the document or user input, extract and transform these fields:

| Field | What to Extract | Rule |
|-------|----------------|------|
| **Title** | Feature or fix name | Rewrite without jargon |
| **Category Badge** | Issue type | One of: `Hata Düzeltmesi` / `Teknik İyileştirme` / `Yeni Özellik` / `Performans` |
| **Hero Headline** | The symptom the end-user experienced | One dramatic sentence — must land emotionally |
| **Hero Accent (before)** | The broken state in 5-8 words | Gradient-highlighted line in hero |
| **Hero Accent (after)** | The fixed state in 5-8 words | Shown when toggle switches to "after" |
| **Hero Sub** | 2-3 sentence expansion of the headline | Describes the pain point clearly |
| **Silent Callout** | A quiet but critical warning | Short sentence with emoji icon |
| **Story Steps** | 3 steps: trigger → failure mechanism → user experience | Named as user actions, not code calls |
| **Root Cause Title** | Why the problem happened | Non-technical analogy preferred |
| **Root Cause Visual** | Interactive proof of the problem | Must respond to before/after toggle |
| **Before List** | 4-5 bullet points of the broken state | Observable effects, not code details |
| **After List** | 4-5 bullet points of the fixed state | Concrete improvements |
| **Contribution** | One sentence summarizing business impact | Format: "Bu düzeltme/iyileştirme ... sağlar." |

### Non-technical language rewrite rules

> [!CAUTION]
> **NEVER expose technical terms in demo-visible text.** If it requires software knowledge to understand, rewrite it.

| Technical Term | Non-technical Replacement |
|----------------|--------------------------|
| NullPointerException, error, exception | "sistem beklenmedik bir durumla karşılaştı" |
| Field name mismatch | "veri doğru gönderildi ama yanlış etiketle" |
| Cache / önbellek | "geçici kopya" (önbellek acceptable if explained) |
| API / endpoint | "servis", "gönderim adresi" |
| null / undefined | "eksik bilgi", "boş alan" |
| Deploy / release | "sisteme alındı", "yayına çıktı" |
| Config / configuration | "yapılandırma", "ayar" |
| Template | "şablon" |
| Provider / vendor | "dış servis", "sağlayıcı" |
| Duplicate record | "iki kez kayıt oluşturuldu" |

### Concrete example rule

> [!IMPORTANT]
> The contribution sentence and impact bullets MUST use concrete, observable statements. Abstract impact alone is not enough.

Good: *"Hasar sorgulayan tüm mobil kullanıcıların katılım tutarı bilgisine eksiksiz erişmesini sağlar."*
Bad: *"Veri tutarsızlığı operasyonel risklere yol açabilir."*

---

## Phase 2: Hero Visual Design

The hero visual is the **most impactful element**. It must be immediately understandable without explanation.

### Selection process

1. Read the document fully.
2. Select the best hero visual type from the table below.
3. Present reasoning to the user and confirm:
   > "Hero görseli için **[type]** seçeceğim çünkü **[1-sentence reason]**. Uygun mu?"

### Hero visual types

| Visual Type | When to Use | Toggle Behavior |
|-------------|-------------|-----------------|
| **Phone Mockup** | Change affects what a mobile customer sees on their device screen | A field value appears blank → reveals correctly on toggle |
| **System Panel Mockup** | Change affects a web admin panel — counters, status indicators, or a button that locks/unlocks | Counter values flash-animate and button state changes |
| **Timeline** | Change eliminates a delay or timing issue in a process | A "delay block" expands in before state, collapses to zero in after state |
| **Custom** | None of the above fits | Describe proposed visual to user, confirm before building |

> [!IMPORTANT]
> Hero visuals are **fully interactive HTML elements** — never a screenshot or static image. They respond to the global before/after toggle.

For detailed HTML skeletons and CSS of each visual type, see [references/HERO-VISUALS.md](references/HERO-VISUALS.md).

---

## Phase 3: Generate Files

Output **exactly 3 files** in `ai/<ISSUE_KEY>/demo/`:

```
ai/<ISSUE_KEY>/demo/
├── index.html
├── style.css
└── app.js
```

### Architecture: Six Sections

Every demo follows the same **section-based before/after architecture**:

| # | Section | CSS Class | Eyebrow Label | Purpose |
|---|---------|-----------|---------------|---------|
| 1 | **Sticky Nav** | `.topnav` | — | Badge + `🐛 Eski Durum / ✅ Yeni Durum` toggle + theme toggle |
| 2 | **Hero** | `.section-hero` | `Sprint Demo · [Month] [Year]` | Dramatic headline + interactive visual |
| 3 | **Story** | `.section-story` | `Ne Yaşandı?` | 3-step story track |
| 4 | **Root Cause** | `.section-rootcause` / `.section-mismatch` / `.section-bugs` | `Kök Neden` | Issue-specific visual proof |
| 5 | **Impact** | `.section-impact` | `Değişim` | Before/after list + contribution bar |
| 6 | **Footer** | `.footer` | — | Sprint info line |

The single `setState('before'|'after')` function drives **all sections simultaneously** when the nav toggle is pressed. No step-by-step scenarios, no auto-play, no pipeline flows.

---

### index.html Structure

Read [references/HTML-STRUCTURE.md](references/HTML-STRUCTURE.md) for the full HTML skeleton template.

Key rules:
- Language is always Turkish (`lang="tr"`)
- Google Fonts: Inter (weights 300-900)
- Body starts with class `theme-dark`
- All interactive elements have `id` attributes for JS manipulation
- Story steps use `reveal` class with `data-delay` for scroll animation
- Root cause section is **issue-specific** — adapt to the nature of the problem

---

### style.css Structure

Read [references/CSS-REFERENCE.md](references/CSS-REFERENCE.md) for the full CSS variable system and component styles.

Key design tokens:
- **Dark theme** is default (`:root` variables)
- **Light theme** overrides via `body.theme-light`
- Color palette: `--green`, `--red`, `--amber`, `--blue`, `--purple`, `--cyan`
- Glow variants for each color: `--green-glow`, `--red-glow`, etc.
- Font: `'Inter', -apple-system, BlinkMacSystemFont, sans-serif`
- Radius system: `--radius-sm` (6px) through `--radius-full` (9999px)
- All sections have `border-top: 1px solid var(--border)` as separator
- Mobile breakpoint at 640-720px

---

### app.js Structure

Read [references/JS-REFERENCE.md](references/JS-REFERENCE.md) for the full JavaScript pattern.

Key patterns:
- `'use strict'` at top
- State variables: `currentState = 'before'`, `currentTheme`
- Boot sequence: set theme → update icon → init reveal → set initial visual state
- `setState(state)` is the **single entry point** for all toggle changes
- Each section has its own `update*` function called from `setState`
- `initReveal()` uses IntersectionObserver for scroll-driven animations
- Theme persistence via `localStorage`
- No external dependencies, no frameworks

---

## Phase 4: Validation

### Visual checklist

Open `index.html` in browser and verify:

```
Validation Checklist:
- [ ] Dark theme renders correctly
- [ ] Light theme renders correctly (click ☀️/🌙)
- [ ] "Eski Durum" toggle shows broken state in ALL sections
- [ ] "Yeni Durum" toggle shows fixed state in ALL sections
- [ ] Hero visual animates smoothly between states
- [ ] Story steps appear with scroll animation
- [ ] Root cause section responds to toggle
- [ ] Before/After lists render with ✕/✓ markers
- [ ] Contribution bar is visible
- [ ] Footer shows correct sprint info
- [ ] Mobile layout works (resize to 360px width)
- [ ] No English text visible in the demo (all Turkish)
- [ ] No technical jargon visible to end user
```

### Code quality checklist

```
Code Quality:
- [ ] No inline styles (everything in style.css)
- [ ] No external dependencies (no CDN except Google Fonts)
- [ ] All interactive elements have meaningful id attributes
- [ ] CSS variables used consistently (no hardcoded colors in components)
- [ ] JavaScript uses var (not let/const) for IE11-safe output
- [ ] No console.log statements
- [ ] Responsive at 640-720px breakpoint
```

---

## Quick Reference

### Section eyebrow labels (always Turkish)

| Section | Eyebrow | Title Pattern |
|---------|---------|---------------|
| Hero | `Sprint Demo · [Ay] [Yıl]` | Dramatic headline |
| Story | `Ne Yaşandı?` | Descriptive subtitle |
| Root Cause | `Kök Neden` | Analogy-based title |
| Impact | `Değişim` | "Küçük düzeltme, büyük fark" pattern |
| Footer | — | `Sprint Demo · <KEY> · <Title> · <Month> <Year>` |

### Toggle button labels

| State | Nav Button | Emoji |
|-------|-----------|-------|
| Before | `Eski Durum` | 🐛 |
| After | `Yeni Durum` | ✅ |

### Category badge colors

| Category | Nav Dot Color |
|----------|--------------|
| Hata Düzeltmesi | `--green` |
| Teknik İyileştirme | `--blue` |
| Yeni Özellik | `--purple` |
| Performans | `--amber` |

---

## Advanced

For detailed reference, see:
- [references/HERO-VISUALS.md](references/HERO-VISUALS.md) — Hero visual type HTML skeletons and CSS
- [references/HTML-STRUCTURE.md](references/HTML-STRUCTURE.md) — Full HTML skeleton template
- [references/CSS-REFERENCE.md](references/CSS-REFERENCE.md) — Complete CSS variable system and component styles
- [references/JS-REFERENCE.md](references/JS-REFERENCE.md) — JavaScript pattern and toggle logic
