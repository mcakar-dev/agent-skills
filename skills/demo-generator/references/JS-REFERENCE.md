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
applyAllSections('before');

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
    var icon = document.getElementById('themeIcon');
    if (icon) icon.textContent = currentTheme === 'dark' ? '☀️' : '🌙';
}

/* ══════════════════════════════════════
   Global State Toggle
══════════════════════════════════════ */
function setState(state) {
    if (currentState === state) return;
    currentState = state;
    applyAllSections(state);
}

function applyAllSections(state) {
    var isBefore = state === 'before';

    // Toggle nav buttons
    document.getElementById('navBtnBefore').classList.toggle('active', isBefore);
    document.getElementById('navBtnAfter').classList.toggle('active', !isBefore);

    // Error-isolated updater chain — each call is wrapped so a
    // single failure does not break the remaining sections.
    var updaters = [
        function () { updateHeroText(isBefore); },
        function () { updateHeroVisual(isBefore); },      // issue-specific
        function () { updateHeroCallout(isBefore); },
        function () { updateStoryTitle(isBefore); },
        function () { updateStoryEndCard(isBefore); },
        function () { updateRootCauseTitle(isBefore); },
        function () { updateRootCause(isBefore); },        // issue-specific
        function () { updateRootCauseCallout(isBefore); }  // if applicable
    ];

    updaters.forEach(function (fn) {
        try { fn(); } catch (e) { /* isolate — do not break chain */ }
    });
}
```

---

## Shared Update Functions

### Hero Text Accent

```javascript
function updateHeroText(isBefore) {
    var accent = document.getElementById('titleAccent');
    if (!accent) return;
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
    if (!callout || !text) return;

    if (isBefore) {
        callout.classList.remove('callout-good');
        text.textContent = '{{Before callout text}}';
    } else {
        callout.classList.add('callout-good');
        text.textContent = '{{After callout text}}';
    }
}
```

### Story Title

The story section title changes between states:

```javascript
function updateStoryTitle(isBefore) {
    var title = document.getElementById('storyTitle');
    if (!title) return;
    if (isBefore) {
        title.textContent = '{{Story Title (before)}}';
    } else {
        title.textContent = '{{Story Title (after)}}';
    }
}
```

### Story End Card (Step 3)

The third story step always responds to the toggle — showing the broken outcome in "before" and the fixed outcome in "after".

> **IMPORTANT:** `id="storyEndIcon"` is placed on the `.sstep-icon-wrap` element itself in the HTML template. Toggle classes (`sstep-bad` / `sstep-good`) must be applied directly to this element — do NOT use `.parentElement`.

```javascript
function updateStoryEndCard(isBefore) {
    var iconWrap = document.getElementById('storyEndIcon');
    var title    = document.getElementById('storyEndTitle');
    var body     = document.getElementById('storyEndBody');
    if (!iconWrap || !title || !body) return;

    iconWrap.classList.remove('sstep-bad', 'sstep-good');

    if (isBefore) {
        iconWrap.textContent = '{{Bad Emoji}}';
        iconWrap.classList.add('sstep-bad');
        title.textContent    = '{{Step 3 Title (before)}}';
        body.textContent     = '{{Step 3 Body (before)}}';
    } else {
        iconWrap.textContent = '{{Good Emoji}}';
        iconWrap.classList.add('sstep-good');
        title.textContent    = '{{Step 3 Title (after)}}';
        body.textContent     = '{{Step 3 Body (after)}}';
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

### Root Cause Title

The root cause section title and subtitle change between states:

```javascript
function updateRootCauseTitle(isBefore) {
    var title = document.getElementById('rcTitle');
    var sub   = document.getElementById('rcSub');
    if (!title || !sub) return;
    if (isBefore) {
        title.textContent = '{{Root Cause Title (before)}}';
        sub.textContent   = '{{Root Cause Sub (before)}}';
    } else {
        title.textContent = '{{Root Cause Title (after)}}';
        sub.textContent   = '{{Root Cause Sub (after)}}';
    }
}
```

### Root Cause Callout

```javascript
function updateRootCauseCallout(isBefore) {
    var body = document.getElementById('rcCalloutBody');
    if (!body) return;
    if (isBefore) {
        body.textContent = '{{Root Cause Callout (before)}}';
    } else {
        body.textContent = '{{Root Cause Callout (after)}}';
    }
}
```

### For Two-Path Root Cause

Use the `hidden` class (`display: none`) to swap path cards. Do **NOT** use opacity-based dimming (`rc-dimmed`) — it leaves the hidden card taking up layout space.

> [!IMPORTANT]
> **LAYOUT RULE:** Two-Path uses `display: block` on `.path-compare` — only one card is visible at a time. This is a **state transition**, NOT a side-by-side comparison. Do NOT add `.path-vs` divider elements or multi-column grids (unless using Pattern D for Live Simulation).

> **WARNING:** Elements that start with `hidden` class must **NOT** also have the `reveal` class. The `hidden` class sets `display:none`, which prevents the IntersectionObserver from ever detecting the element. When `hidden` is later removed, the element stays at `opacity:0` from `reveal` because `visible` was never added. See the **Class Interaction Rules** section for details.

```javascript
function updateRootCause(isBefore) {
    var pathBad  = document.getElementById('pathBad');
    var pathGood = document.getElementById('pathGood');
    if (!pathBad || !pathGood) return;

    if (isBefore) {
        pathBad.classList.remove('hidden');
        pathGood.classList.add('hidden');
    } else {
        pathBad.classList.add('hidden');
        pathGood.classList.remove('hidden');
    }

    var cfgOld = document.getElementById('cfgOld');
    var cfgNew = document.getElementById('cfgNew');
    if (cfgOld) cfgOld.classList.toggle('rc-active', isBefore);
    if (cfgNew) cfgNew.classList.toggle('rc-active', !isBefore);
}
```

### For Simulation (Pattern D)

Simulation scenarios (Canlı Karşılaştırma) require asynchronous logic to simulate time or parallel processes. Use `setTimeout` and CSS class toggles (`.node-active`, `.node-done`, `.lat-counting`) to drive progress bars or latency timers. Provide a reset function.

```javascript
var simTimeoutsBefore = [];
var simTimeoutsAfter = [];

function clearSimTimeouts(mode) {
    if (mode === 'both' || mode === 'before') {
        simTimeoutsBefore.forEach(function(t) { clearTimeout(t); });
        simTimeoutsBefore = [];
    }
    if (mode === 'both' || mode === 'after') {
        simTimeoutsAfter.forEach(function(t) { clearTimeout(t); });
        simTimeoutsAfter = [];
    }
}

function startSimulation(mode) {
    clearSimTimeouts(mode);
    
    // DO NOT change opacity. Both panels must remain fully visible.
    var panelBefore = document.querySelector('.sim-panel-bad');
    var panelAfter  = document.querySelector('.sim-panel-good');
    if (panelBefore && panelAfter) {
        panelBefore.style.opacity = '1';
        panelAfter.style.opacity = '1';
    }
    
    if (mode === 'both' || mode === 'before') {
        // 1. Reset ONLY 'before' (Left panel) elements to initial states
        var pbBefore = document.getElementById('simProgressBarBefore');
        if (pbBefore) pbBefore.style.width = '0%';
        
        // 2. Start 'before' progress/timer
        simTimeoutsBefore.push(setTimeout(function() {
            if (pbBefore) pbBefore.style.width = '100%';
            // Toggle other states here
        }, 100));
    }
    
    if (mode === 'both' || mode === 'after') {
        // 1. Reset ONLY 'after' (Right panel) elements to initial states
        var pbAfter = document.getElementById('simProgressBarAfter');
        if (pbAfter) pbAfter.style.width = '0%';
        
        // 2. Start 'after' progress/timer
        simTimeoutsAfter.push(setTimeout(function() {
            if (pbAfter) pbAfter.style.width = '100%';
            // Toggle other states here
        }, 100));
    }
}

// In applyAllSections, you may reset the simulation when toggling states
function updateSimulationState(isBefore) {
    clearSimTimeouts('both');
    // Reset visually
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
    if (!el) return;

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
setState(state)
  └── applyAllSections(state)
        ├── Toggle nav button active classes
        ├── try: updateHeroText(isBefore)
        ├── try: updateHeroVisual(isBefore)          ← issue-specific
        ├── try: updateHeroCallout(isBefore)
        ├── try: updateStoryTitle(isBefore)
        ├── try: updateStoryEndCard(isBefore)
        ├── try: updateRootCauseTitle(isBefore)
        ├── try: updateRootCause(isBefore)            ← issue-specific
        ├── try: updateRootCauseCallout(isBefore)     ← if applicable
        └── [additional updaters as needed]
```

Every function receives a single `isBefore` boolean. Each function is responsible for one visual section only. Each call is wrapped in `try/catch` so a single failure does not break the remaining sections.

---

## Defensive Coding Rules

> [!CAUTION]
> These rules are **mandatory**. Every reference pattern in this file already follows them. When adapting for a specific issue, apply the same discipline.

| Rule | Detail |
|------|--------|
| **Null guard every getElementById** | Start each update function with `if (!el) return;` after querying the DOM. A missing `id` in HTML must not crash the entire toggle chain. |
| **Error-isolated updater chain** | `applyAllSections` wraps each updater in `try/catch`. This ensures a failure in one section does not prevent the remaining sections from updating. |
| **No parentElement traversal** | Target the exact element that owns the class. Using `el.parentElement.classList` couples JS to DOM nesting depth, which is fragile. If the `id` is on the wrapper, operate on it directly. |
| **Boot calls applyAllSections** | The boot sequence must call `applyAllSections('before')` to synchronize HTML defaults with JS state. A commented-out init line is a bug waiting to happen. |

---

## Class Interaction Rules

> [!CAUTION]
> **`hidden` and `reveal` must NEVER coexist on the same element.**

The `hidden` class applies `display: none !important`, which removes the element from layout. The `reveal` class applies `opacity: 0` and relies on `IntersectionObserver` to add the `visible` class. If both are on the same element:

1. `display: none` prevents the element from entering the viewport
2. `IntersectionObserver` never fires → `visible` is never added
3. When `hidden` is removed via JS toggle, `reveal` keeps the element at `opacity: 0`
4. The element is invisible despite not being hidden

**Resolution:** Elements that toggle via `hidden` class must **not** have `reveal`. They appear/disappear instantly. Only elements that are always in the DOM flow should use `reveal` for scroll animation.
