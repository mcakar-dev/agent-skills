# JavaScript Reference

Complete JavaScript pattern for demo interactivity. All demos share the same core structure with issue-specific update functions.

---

## Core Structure

```javascript
'use strict';

/* ══════════════════════════════════════
   State
══════════════════════════════════════ */
var currentState = 'before';
var currentTheme = localStorage.getItem('theme') || 'dark';

/* ══════════════════════════════════════
   Boot
══════════════════════════════════════ */
document.body.className = 'theme-' + currentTheme;
updateThemeIcon();
initReveal();

// Set initial visual state
// applyHeroVisualState('before');  // call issue-specific init here

/* ══════════════════════════════════════
   Theme
══════════════════════════════════════ */
function toggleTheme() {
    currentTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.body.className = 'theme-' + currentTheme;
    localStorage.setItem('theme', currentTheme);
    updateThemeIcon();
}

function updateThemeIcon() {
    document.getElementById('themeIcon').textContent = currentTheme === 'dark' ? '☀️' : '🌙';
}

/* ══════════════════════════════════════
   Global State Toggle
══════════════════════════════════════ */
function setState(state) {
    if (currentState === state) return;
    currentState = state;

    var isBefore = state === 'before';

    // Toggle nav buttons
    document.getElementById('navBtnBefore').classList.toggle('active', isBefore);
    document.getElementById('navBtnAfter').classList.toggle('active', !isBefore);

    // Update ALL sections — each has its own function
    updateHeroText(isBefore);
    updateHeroVisual(isBefore);     // issue-specific
    updateHeroCallout(isBefore);
    updateStoryEndCard(isBefore);
    updateRootCause(isBefore);      // issue-specific
    // Add more section updaters as needed
}
```

---

## Shared Update Functions

### Hero Text Accent

```javascript
function updateHeroText(isBefore) {
    var accent = document.getElementById('titleAccent');
    if (isBefore) {
        accent.textContent = '{{Hero Accent Before}}';
        accent.classList.remove('fixed');
    } else {
        accent.textContent = '{{Hero Accent After}}';
        accent.classList.add('fixed');
    }
}
```

### Hero Callout

```javascript
function updateHeroCallout(isBefore) {
    var callout = document.getElementById('heroCallout');
    var text    = document.getElementById('heroCalloutText');

    if (isBefore) {
        callout.classList.remove('callout-good');
        text.textContent = '{{Before callout text}}';
    } else {
        callout.classList.add('callout-good');
        text.textContent = '{{After callout text}}';
    }
}
```

### Story End Card (Step 3)

The third story step always responds to the toggle — showing the broken outcome in "before" and the fixed outcome in "after":

```javascript
function updateStoryEndCard(isBefore) {
    var icon  = document.getElementById('storyEndIcon');
    var title = document.getElementById('storyEndTitle');
    var body  = document.getElementById('storyEndBody');

    icon.parentElement.classList.remove('sstep-bad', 'sstep-good');

    if (isBefore) {
        icon.textContent  = '{{Bad Emoji}}';
        icon.parentElement.classList.add('sstep-bad');
        title.textContent = '{{Step 3 Title (before)}}';
        body.innerHTML    = '{{Step 3 Body (before)}}';
    } else {
        icon.textContent  = '{{Good Emoji}}';
        icon.parentElement.classList.add('sstep-good');
        title.textContent = '{{Step 3 Title (after)}}';
        body.innerHTML    = '{{Step 3 Body (after)}}';
    }
}
```

---

## Issue-Specific Update Functions

### For Mismatch Root Cause

```javascript
function updateMismatchSection(isBefore) {
    var maiSymbol = document.getElementById('maiSymbol');
    var maiLabel  = document.getElementById('maiLabel');
    var mirBad    = document.getElementById('mirBad');
    var mirGood   = document.getElementById('mirGood');
    var fnReceiverDiff = document.getElementById('fnReceiverDiff');
    var mcsBad  = document.getElementById('mcsBad');
    var mcsGood = document.getElementById('mcsGood');

    if (isBefore) {
        maiSymbol.textContent = '≠';
        maiSymbol.classList.remove('matched');
        maiLabel.textContent  = 'Eşleşme yok';
        maiLabel.classList.remove('matched');
        mirBad.classList.remove('hidden');
        mirGood.classList.add('hidden');
        fnReceiverDiff.textContent = '{{wrong suffix}}';
        fnReceiverDiff.classList.remove('fn-fixed', 'fn-match');
        fnReceiverDiff.classList.add('fn-mismatch');
        mcsBad.classList.remove('hidden');
        mcsGood.classList.add('hidden');
    } else {
        maiSymbol.textContent = '=';
        maiSymbol.classList.add('matched');
        maiLabel.textContent  = 'Eşleşme sağlandı';
        maiLabel.classList.add('matched');
        mirBad.classList.add('hidden');
        mirGood.classList.remove('hidden');
        fnReceiverDiff.classList.add('fn-fixed', 'fn-match');
        fnReceiverDiff.classList.remove('fn-mismatch');
        setTimeout(function () {
            fnReceiverDiff.textContent = '{{correct suffix}}';
        }, 80);
        mcsBad.classList.add('hidden');
        mcsGood.classList.remove('hidden');
    }
}
```

### For Two-Bug Root Cause

```javascript
function updateBugCards(isBefore) {
    // Update math values in bug cards
    var bm1Result = document.getElementById('bm1Pending');
    var bugFix1   = document.getElementById('bugFix1');

    if (isBefore) {
        bm1Result.innerHTML = '{{broken calculation}} ⚠';
        bugFix1.classList.remove('strip-active');
    } else {
        bm1Result.innerHTML = '{{fixed calculation}} <strong style="color:var(--green)">0 ✓</strong>';
        bugFix1.classList.add('strip-active');
    }
    // Repeat for Bug 2, combined equation, etc.
}

function updateCombinedEquation(isBefore) {
    var eq  = document.querySelector('.combined-equation');
    var t   = document.getElementById('ceqTitle');
    var sub = document.getElementById('ceqSub');

    if (isBefore) {
        eq.classList.remove('ceq-good');
        t.innerHTML   = '{{broken total}}';
        sub.textContent = '{{broken explanation}}';
    } else {
        eq.classList.add('ceq-good');
        t.innerHTML   = '{{fixed total}}';
        sub.textContent = '{{fixed explanation}}';
    }
}
```

### For Two-Path Root Cause

```javascript
function updateRootCause(isBefore) {
    var pathBad  = document.getElementById('pathBad');
    var pathGood = document.getElementById('pathGood');
    var cfgOld   = document.getElementById('cfgOld');
    var cfgNew   = document.getElementById('cfgNew');

    if (isBefore) {
        pathBad.classList.remove('rc-dimmed');
        pathGood.classList.add('rc-dimmed');
        if (cfgOld) cfgOld.classList.add('rc-active');
        if (cfgNew) cfgNew.classList.remove('rc-active');
    } else {
        pathBad.classList.add('rc-dimmed');
        pathGood.classList.remove('rc-dimmed');
        if (cfgOld) cfgOld.classList.remove('rc-active');
        if (cfgNew) cfgNew.classList.add('rc-active');
    }
}
```

---

## Scroll-Driven Reveal (IntersectionObserver)

This is **always the same** across all demos. Copy verbatim.

```javascript
function initReveal() {
    var elements = document.querySelectorAll('.reveal');

    if (!('IntersectionObserver' in window)) {
        elements.forEach(function (el) { el.classList.add('visible'); });
        return;
    }

    var observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            var el    = entry.target;
            var delay = parseInt(el.getAttribute('data-delay') || '0', 10);
            setTimeout(function () {
                el.classList.add('visible');
            }, delay);
            observer.unobserve(el);
        });
    }, { threshold: 0.12, rootMargin: '0px 0px -30px 0px' });

    elements.forEach(function (el) { observer.observe(el); });
}
```

---

## Counter Animation Helper

Used by System Panel hero visual. Reusable for any counter-based UI.

```javascript
function applyCounter(elementId, data) {
    var el     = document.getElementById(elementId);
    var noteEl = document.getElementById(elementId + 'Note');

    // Flash animation
    el.style.animation = 'none';
    void el.offsetWidth;
    el.style.animation = 'countFlash 0.45s ease forwards';

    el.textContent = data.value;

    if (noteEl) {
        noteEl.textContent = data.note;
        noteEl.className   = 'stat-note ' + data.noteClass;
    }
}
```

---

## Key Rules

| Rule | Detail |
|------|--------|
| Use `var` not `let/const` | Broader compatibility |
| No external dependencies | No jQuery, no frameworks |
| No `console.log` | Clean output only |
| `'use strict'` at top | Always |
| Theme via `localStorage` | Persists across page reloads |
| `setState` is single entry | ALL visual changes flow through this one function |
| Each section has own updater | `updateHeroText`, `updateStoryEndCard`, etc. |
| `initReveal` is always the same | Copy verbatim, do not modify |
| `void el.offsetWidth` | Forces reflow for animation restart |

---

## setState Call Flow Diagram

```
setState('before' | 'after')
  ├── Toggle nav button active classes
  ├── updateHeroText(isBefore)
  ├── updateHeroVisual(isBefore)        ← issue-specific
  ├── updateHeroCallout(isBefore)
  ├── updateStoryEndCard(isBefore)
  ├── updateRootCause(isBefore)         ← issue-specific
  └── [additional updaters as needed]
```

Every function receives a single `isBefore` boolean. Each function is responsible for one visual section only.
