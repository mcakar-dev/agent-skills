# Demo Generator — Design System

The full CSS design system for all generated sprint demos. Copy `:root` variables and component blocks as-is. Never deviate from this palette.

---

## CSS Variables (`:root`)

Define two theme blocks. `:root` is **dark** (default). `body.theme-light` overrides all background, border, and text variables for light mode. Semantic color variables (`--green`, `--red`, etc.) do NOT change between themes.

```css
:root {
    /* Backgrounds */
    --bg:           #060b18;
    --bg-card:      #0d1425;
    --bg-elevated:  #131c33;
    --bg-surface:   #1a2540;

    /* Borders */
    --border:       #1e2d4a;
    --border-light: #2a3f65;

    /* Text */
    --text:         #e0e7f1;
    --text-muted:   #7b8fad;
    --text-heading: #f0f4f8;
    --text-dim:     #4a5f80;

    /* Semantic colors — unchanged in light mode */
    --green:        #34d399;
    --green-glow:   rgba(52, 211, 153, 0.25);
    --green-muted:  rgba(52, 211, 153, 0.12);

    --red:          #f87171;
    --red-glow:     rgba(248, 113, 113, 0.25);
    --red-muted:    rgba(248, 113, 113, 0.10);

    --amber:        #fbbf24;
    --amber-glow:   rgba(251, 191, 36, 0.25);
    --amber-muted:  rgba(251, 191, 36, 0.10);

    --blue:         #60a5fa;
    --blue-glow:    rgba(96, 165, 250, 0.25);
    --blue-muted:   rgba(96, 165, 250, 0.10);

    --purple:       #a78bfa;
    --purple-glow:  rgba(167, 139, 250, 0.25);

    --cyan:         #22d3ee;
    --cyan-glow:    rgba(34, 211, 238, 0.20);

    /* Border radius */
    --radius-sm:   8px;
    --radius-md:   12px;
    --radius-lg:   16px;
    --radius-xl:   24px;
    --radius-full: 100px;

    /* Typography */
    --font: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;

    /* UI Mockup Panel */
    --mockup-bg: #080f1e;
}

/* =============================================
   Light Theme Override — applied when body has class="theme-light"
   ============================================= */

body.theme-light {
    --bg:           #f0f4f8;
    --bg-card:      #ffffff;
    --bg-elevated:  #e8eef5;
    --bg-surface:   #dde6f0;

    --border:       #c8d6e5;
    --border-light: #a8bdd0;

    --text:         #1e2d40;
    --text-muted:   #5a7a9a;
    --text-heading: #0f1e2e;
    --text-dim:     #8aa0b8;

    /* UI Mockup Panel — lighter background in light mode */
    --mockup-bg: #f8faff;
}

/* Ambient glow is subtler in light mode */
body.theme-light::before {
    background:
        radial-gradient(ellipse at 15% 10%, rgba(96, 165, 250, 0.07) 0%, transparent 50%),
        radial-gradient(ellipse at 85% 90%, rgba(52, 211, 153, 0.05) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 50%, rgba(167, 139, 250, 0.04) 0%, transparent 60%);
}

/* System log background stays dark in light mode for readability */
body.theme-light .sys-log { background: #1a1f2e; }
body.theme-light .sys-log-header { background: #252d40; color: #7b8fad; }
```

---

## Base Reset

```css
*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

html { font-size: 16px; scroll-behavior: smooth; }

body {
    font-family: var(--font);
    background: var(--bg);
    color: var(--text);
    line-height: 1.6;
    min-height: 100vh;
    overflow-x: hidden;
}

/* Ambient background glow — always include */
body::before {
    content: '';
    position: fixed;
    inset: 0;
    background:
        radial-gradient(ellipse at 15% 10%, rgba(96, 165, 250, 0.05) 0%, transparent 50%),
        radial-gradient(ellipse at 85% 90%, rgba(52, 211, 153, 0.04) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 50%, rgba(167, 139, 250, 0.03) 0%, transparent 60%);
    pointer-events: none;
    z-index: 0;
}

.app {
    position: relative;
    z-index: 1;
    max-width: 1100px;          /* fits 720p (1280×720) comfortably */
    margin: 0 auto;
    padding: 2rem 2.5rem;
}
```

---

## Theme Toggle Button

```css
.theme-toggle {
    position: fixed;
    top: 1rem;
    right: 1rem;
    z-index: 1000;
    width: 40px;
    height: 40px;
    border-radius: var(--radius-full);
    border: 1.5px solid var(--border-light);
    background: var(--bg-card);
    font-size: 1rem;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;
    box-shadow: 0 2px 12px rgba(0,0,0,0.3);
}
.theme-toggle:hover {
    transform: scale(1.1);
    border-color: var(--blue);
    box-shadow: 0 0 16px var(--blue-glow);
}
```

---

## Header — STANDARD

```css
.header { text-align: center; padding: 2rem 0 1.5rem; }

.header-badge {
    display: inline-block;
    font-size: 0.65rem;
    font-weight: 700;
    letter-spacing: 2.5px;
    text-transform: uppercase;
    padding: 0.35rem 1rem;
    border-radius: var(--radius-full);
    background: linear-gradient(135deg, var(--blue), var(--purple));
    color: white;
    margin-bottom: 1rem;
    animation: softPulse 3s ease-in-out infinite;
}

.header-title {
    font-size: 2.2rem;
    font-weight: 800;
    letter-spacing: -0.5px;
    background: linear-gradient(135deg, var(--text-heading) 30%, var(--blue) 60%, var(--cyan));
    background-size: 200% auto;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: shimmer 5s linear infinite;
    margin-bottom: 0.4rem;
}

.header-subtitle { font-size: 0.95rem; color: var(--text-muted); }
```

## Header — HERO

```css
.hero {
    text-align: center;
    padding: 3.5rem 2rem 2.5rem;
    background: linear-gradient(160deg, #0f1f42 0%, #0a1628 50%, #060b18 100%);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-light);
    margin-bottom: 2rem;
    position: relative;
    overflow: hidden;
}

.hero::before {
    content: '';
    position: absolute;
    inset: 0;
    background:
        radial-gradient(ellipse at 30% 20%, rgba(96, 165, 250, 0.12) 0%, transparent 50%),
        radial-gradient(ellipse at 70% 80%, rgba(167, 139, 250, 0.08) 0%, transparent 50%);
    pointer-events: none;
}

.hero-badge {
    display: inline-block;
    font-size: 0.6rem;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
    padding: 0.4rem 1.2rem;
    border-radius: var(--radius-full);
    border: 1px solid rgba(96, 165, 250, 0.4);
    color: var(--blue);
    background: rgba(96, 165, 250, 0.08);
    margin-bottom: 1.5rem;
    position: relative;
}

.hero-title {
    font-size: clamp(1.8rem, 4vw, 2.8rem);
    font-weight: 800;
    letter-spacing: -0.5px;
    color: var(--text-heading);
    margin-bottom: 1rem;
    position: relative;
    line-height: 1.2;
}

.hero-subtitle {
    font-size: 1rem;
    color: var(--text-muted);
    max-width: 560px;
    margin: 0 auto;
    position: relative;
}
```

---

## Why/What/Benefit Cards

```css
.why-section {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin-bottom: 2rem;
}

.why-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 1.5rem;
    position: relative;
    transition: transform 0.2s;
}
.why-card:hover { transform: translateY(-2px); }

.why-card h3 { font-size: 0.85rem; font-weight: 700; margin-bottom: 0.75rem; }

.why-problem { border-top: 3px solid var(--amber); }
.why-problem h3 { color: var(--amber); }

.why-solution { border-top: 3px solid var(--green); }
.why-solution h3 { color: var(--green); }

.why-benefit { border-top: 3px solid var(--blue); }
.why-benefit h3 { color: var(--blue); }

/* Highlighted example box inside why-problem */
.why-example {
    margin-top: 0.75rem;
    padding: 0.75rem;
    background: var(--amber-muted);
    border-left: 3px solid var(--amber);
    border-radius: var(--radius-sm);
    font-size: 0.8rem;
    color: var(--text);
    font-style: italic;
    line-height: 1.5;
}

.why-card ul { padding-left: 1rem; }
.why-card ul li { font-size: 0.82rem; margin-bottom: 0.4rem; color: var(--text); }

.benefit-list { list-style: none; padding: 0; }
.benefit-list li { display: flex; align-items: flex-start; gap: 0.4rem; font-size: 0.82rem; margin-bottom: 0.4rem; }
.check { color: var(--green); font-weight: 700; flex-shrink: 0; }

@media (max-width: 640px) {
    .why-section { grid-template-columns: 1fr; }
}
```

---

## Navigation Buttons

```css
.controls {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.65rem 1.25rem;
    border: 1.5px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--bg-card);
    color: var(--text);
    font-family: var(--font);
    font-size: 0.82rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}
.btn:hover { transform: translateY(-2px); }
.btn:active { transform: translateY(0); }
.btn.active { transform: translateY(0) !important; }

.btn-normal  { border-color: rgba(52, 211, 153, 0.3); }
.btn-normal:hover, .btn-normal.active  { border-color: var(--green); box-shadow: 0 0 20px var(--green-glow); background: var(--green-muted); color: var(--green); }

.btn-problem { border-color: rgba(248, 113, 113, 0.3); }
.btn-problem:hover, .btn-problem.active { border-color: var(--red); box-shadow: 0 0 20px var(--red-glow); background: var(--red-muted); color: var(--red); }

.btn-fix     { border-color: rgba(96, 165, 250, 0.3); }
.btn-fix:hover, .btn-fix.active     { border-color: var(--blue); box-shadow: 0 0 20px var(--blue-glow); background: var(--blue-muted); color: var(--blue); }

.btn-reset   { border-color: rgba(123, 143, 173, 0.2); color: var(--text-muted); }
.btn-reset:hover { border-color: var(--border-light); color: var(--text); }

.btn-autoplay { border-color: rgba(167, 139, 250, 0.3); }
.btn-autoplay:hover, .btn-autoplay.active { border-color: var(--purple); box-shadow: 0 0 20px var(--purple-glow); background: rgba(167, 139, 250, 0.1); color: var(--purple); }

/* Step counter */
.step-counter {
    font-size: 0.75rem;
    color: var(--text-muted);
    padding: 0.3rem 0.75rem;
    border: 1px solid var(--border);
    border-radius: var(--radius-full);
    font-variant-numeric: tabular-nums;
}

/* Scenario toggle (2-state, INTERACTIVE_SIMULATION) */
.scenario-toggle {
    display: inline-flex;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    overflow: hidden;
    margin-bottom: 1.5rem;
}
.toggle-btn {
    padding: 0.6rem 1.2rem;
    font-size: 0.82rem;
    font-weight: 600;
    font-family: var(--font);
    cursor: pointer;
    border: none;
    background: var(--bg-card);
    color: var(--text-muted);
    transition: all 0.2s;
}
.toggle-btn.active-problem { background: var(--red-muted); color: var(--red); }
.toggle-btn.active-fix     { background: var(--green-muted); color: var(--green); }
```

---

## Scenario Banner

```css
.scenario-banner {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1.25rem;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    background: var(--bg-card);
    margin-bottom: 1.5rem;
    font-size: 0.85rem;
    color: var(--text-muted);
    transition: all 0.3s;
}
.banner-normal  { border-color: rgba(52, 211, 153, 0.3);  background: var(--green-muted); color: var(--green); }
.banner-problem { border-color: rgba(248, 113, 113, 0.3); background: var(--red-muted);   color: var(--red); }
.banner-fix     { border-color: rgba(96, 165, 250, 0.3);  background: var(--blue-muted);  color: var(--blue); }
```

---

## Flow Nodes (PIPELINE & BRANCH_FLOW)

```css
/* Step wrapper (PIPELINE) */
.pipe-step {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem 1.25rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
    opacity: 0;
    transform: translateX(-12px);
    transition: opacity 0.35s, transform 0.35s, border-color 0.3s, box-shadow 0.3s;
}
.pipe-step.visible { opacity: 1; transform: translateX(0); }
.pipe-step.glow-green { border-color: rgba(52, 211, 153, 0.4); box-shadow: 0 0 20px var(--green-glow); }
.pipe-step.glow-red   { border-color: rgba(248, 113, 113, 0.4); box-shadow: 0 0 20px var(--red-glow); }
.pipe-step.glow-blue  { border-color: rgba(96, 165, 250, 0.4); box-shadow: 0 0 20px var(--blue-glow); }
.pipe-step.glow-amber { border-color: rgba(251, 191, 36, 0.4); box-shadow: 0 0 20px var(--amber-glow); }

.pipe-node {
    width: 44px; height: 44px;
    border-radius: var(--radius-md);
    background: var(--bg-elevated);
    border: 1px solid var(--border-light);
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    flex-shrink: 0;
    font-size: 1.1rem;
}

/* Connector line between steps */
.pipe-connector { padding: 0 0 0 2.5rem; }
.connector-line {
    width: 2px; height: 28px;
    background: var(--border);
    position: relative;
    transition: background 0.3s;
}
.line-green { background: var(--green); }
.line-red   { background: var(--red); }
.line-blue  { background: var(--blue); }
.line-broken { background: repeating-linear-gradient(to bottom, var(--amber) 0, var(--amber) 4px, transparent 4px, transparent 8px); }

.connector-pulse {
    position: absolute;
    top: 0; left: 50%;
    transform: translateX(-50%);
    width: 6px; height: 6px;
    border-radius: 50%;
    animation: none;
}
.pulse-green { background: var(--green); animation: pulseDown 0.8s ease forwards; }
.pulse-red   { background: var(--red);   animation: pulseDown 0.8s ease forwards; }
.pulse-blue  { background: var(--blue);  animation: pulseDown 0.8s ease forwards; }

/* Flow node card (BRANCH_FLOW / INTERACTIVE_SIMULATION) */
.fv-card {
    padding: 0.85rem 1rem;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    background: var(--bg-card);
    text-align: center;
    min-width: 100px;
    transition: border-color 0.3s, box-shadow 0.3s;
}
.fv-card .fv-emoji { font-size: 1.4rem; margin-bottom: 0.25rem; }
.fv-card .fv-name  { font-size: 0.78rem; font-weight: 600; color: var(--text); }
.fv-card .fv-sub   { font-size: 0.7rem; color: var(--text-muted); margin-top: 0.15rem; }
```

---

## Info Panel

```css
.info-panel {
    padding: 1.25rem 1.5rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
    margin: 1.5rem 0;
    transition: border-color 0.3s, background 0.3s;
}
.info-green  { border-color: rgba(52, 211, 153, 0.3);  background: var(--green-muted); }
.info-red    { border-color: rgba(248, 113, 113, 0.3); background: var(--red-muted); }
.info-blue   { border-color: rgba(96, 165, 250, 0.3);  background: var(--blue-muted); }
.info-amber  { border-color: rgba(251, 191, 36, 0.3);  background: var(--amber-muted); }

.info-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem; }
.info-title  { font-weight: 700; font-size: 0.9rem; color: var(--text-heading); }
.info-body   { font-size: 0.85rem; color: var(--text); line-height: 1.65; }
.info-body strong { color: var(--text-heading); }
```

---

## Impact Section

```css
.impact-section {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 1rem;
    align-items: center;
    margin: 1.5rem 0;
}
.impact-card {
    padding: 1.25rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
}
.impact-before { border-top: 3px solid var(--red); }
.impact-after  { border-top: 3px solid var(--green); }
.impact-label  { font-size: 0.75rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 0.75rem; }
.impact-before .impact-label { color: var(--red); }
.impact-after  .impact-label { color: var(--green); }
.impact-list   { list-style: none; padding: 0; }
.impact-list li { font-size: 0.82rem; padding: 0.3rem 0; border-bottom: 1px solid var(--border); color: var(--text); }
.impact-list li:last-child { border-bottom: none; }
.impact-arrow  { font-size: 1.5rem; color: var(--text-dim); text-align: center; }

@media (max-width: 640px) {
    .impact-section { grid-template-columns: 1fr; }
    .impact-arrow { display: none; }
}
```

---

## Summary Cards

```css
.summary-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin: 1.5rem 0;
}
.summary-card {
    padding: 1.25rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
}
.summary-problem { border-left: 4px solid var(--red); }
.summary-solution { border-left: 4px solid var(--green); }
.summary-header { display: flex; align-items: center; gap: 0.5rem; font-size: 0.75rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 0.6rem; }
.summary-problem .summary-header  { color: var(--red); }
.summary-solution .summary-header { color: var(--green); }
.summary-body  { font-size: 0.82rem; color: var(--text); line-height: 1.6; }
.summary-body strong { color: var(--text-heading); }

@media (max-width: 640px) { .summary-section { grid-template-columns: 1fr; } }
```

---

## Screenshot Section

### Before/After Slider

```css
.screenshot-section {
    margin: 1.5rem 0;
}
.ss-title {
    font-size: 0.8rem;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 0.75rem;
}
.ss-slider-container {
    position: relative;
    border-radius: var(--radius-lg);
    overflow: hidden;
    border: 1px solid var(--border);
    user-select: none;
    cursor: col-resize;
    max-height: 480px;
}
.ss-before,
.ss-after {
    position: absolute;
    inset: 0;
    overflow: hidden;
}
.ss-before {
    z-index: 2;
    width: 50%;   /* controlled by JS drag */
}
.ss-after {
    z-index: 1;
    width: 100%;
}
.ss-before img,
.ss-after img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    pointer-events: none;
}
/* Placeholder sizing for the container */
.ss-slider-container::after {
    content: '';
    display: block;
    padding-top: 56.25%;   /* 16:9 aspect ratio */
}
.ss-divider {
    position: absolute;
    top: 0; bottom: 0;
    left: 50%;   /* controlled by JS */
    z-index: 3;
    width: 3px;
    background: white;
    cursor: col-resize;
    transform: translateX(-50%);
}
.ss-handle {
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    width: 36px; height: 36px;
    border-radius: 50%;
    background: white;
    color: #1a2540;
    font-size: 1rem;
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 2px 12px rgba(0,0,0,0.4);
    font-weight: 700;
}
.ss-label {
    position: absolute;
    top: 0.75rem;
    z-index: 4;
    font-size: 0.65rem;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 0.25rem 0.6rem;
    border-radius: var(--radius-full);
    pointer-events: none;
}
.ss-label-before { left: 0.75rem;  background: var(--red-muted);   color: var(--red);   border: 1px solid rgba(248,113,113,0.3); }
.ss-label-after  { right: 0.75rem; background: var(--green-muted); color: var(--green); border: 1px solid rgba(52,211,153,0.3); }
```

**Before/After Slider JS:**
```js
function initSlider() {
    const container = document.querySelector('.ss-slider-container');
    const divider   = document.getElementById('ssDivider');
    const before    = document.querySelector('.ss-before');
    if (!container || !divider) return;

    let dragging = false;

    function setPosition(clientX) {
        const rect = container.getBoundingClientRect();
        let pct = (clientX - rect.left) / rect.width * 100;
        pct = Math.max(5, Math.min(95, pct));
        before.style.width  = pct + '%';
        divider.style.left  = pct + '%';
    }

    divider.addEventListener('mousedown',  () => { dragging = true; });
    document.addEventListener('mousemove', e => { if (dragging) setPosition(e.clientX); });
    document.addEventListener('mouseup',   () => { dragging = false; });

    divider.addEventListener('touchstart',  () => { dragging = true; }, { passive: true });
    document.addEventListener('touchmove',  e => { if (dragging) setPosition(e.touches[0].clientX); }, { passive: true });
    document.addEventListener('touchend',   () => { dragging = false; });
}

document.addEventListener('DOMContentLoaded', initSlider);
```

### Gallery + Lightbox

```css
.ss-gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 0.75rem;
}
.ss-card {
    border-radius: var(--radius-md);
    overflow: hidden;
    border: 1px solid var(--border);
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
}
.ss-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    border-color: var(--blue);
}
.ss-card img { width: 100%; height: 140px; object-fit: cover; display: block; }
.ss-card-label {
    padding: 0.4rem 0.6rem;
    font-size: 0.72rem;
    color: var(--text-muted);
    background: var(--bg-card);
}

/* Lightbox */
.ss-lightbox {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.85);
    z-index: 2000;
    align-items: center;
    justify-content: center;
    cursor: pointer;
}
.ss-lightbox.open { display: flex; }
.ss-lightbox-inner {
    position: relative;
    max-width: 90vw;
    max-height: 86vh;
    cursor: default;
}
.ss-lightbox-inner img {
    max-width: 100%;
    max-height: 80vh;
    border-radius: var(--radius-lg);
    display: block;
}
.ss-lightbox-caption {
    text-align: center;
    margin-top: 0.6rem;
    font-size: 0.82rem;
    color: #e0e7f1;
}
.ss-lightbox-close {
    position: absolute;
    top: -0.75rem; right: -0.75rem;
    width: 30px; height: 30px;
    border-radius: 50%;
    background: var(--red);
    color: white;
    border: none;
    font-size: 0.8rem;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
}
```

**Lightbox JS:**
```js
function openLightbox(src, caption) {
    document.getElementById('ssLightboxImg').src = src;
    document.getElementById('ssLightboxCaption').textContent = caption || '';
    document.getElementById('ssLightbox').classList.add('open');
}
function closeLightbox() {
    document.getElementById('ssLightbox').classList.remove('open');
}
```

---

## System Logs (INTERACTIVE_SIMULATION)

```css
.sys-log {
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    background: #020609;
    overflow: hidden;
    margin-top: 1rem;
}
.sys-log-header {
    padding: 0.4rem 1rem;
    font-size: 0.65rem;
    font-weight: 700;
    letter-spacing: 2px;
    color: var(--text-dim);
    background: var(--bg-card);
    border-bottom: 1px solid var(--border);
}
.sys-log-body {
    padding: 0.75rem 1rem;
    font-family: 'Courier New', monospace;
    font-size: 0.75rem;
    color: #4ade80;
    min-height: 80px;
    max-height: 140px;
    overflow-y: auto;
    line-height: 1.7;
}
.log-muted   { color: var(--text-dim); }
.log-success { color: var(--green); }
.log-warn    { color: var(--amber); }
.log-error   { color: var(--red); }
```

---

## Phone Mockup

```css
.phone-mockup {
    width: 180px;
    border-radius: 28px;
    border: 8px solid #1a2540;
    background: #0d1425;
    overflow: hidden;
    box-shadow: 0 0 30px rgba(0,0,0,0.6);
    flex-shrink: 0;
}
.phone-notch {
    width: 60px; height: 10px;
    background: #1a2540;
    border-radius: 0 0 8px 8px;
    margin: 0 auto 0.5rem;
}
.phone-screen { padding: 0.5rem 0.75rem 1rem; min-height: 200px; }
.phone-label  { font-size: 0.6rem; color: var(--text-dim); text-align: right; margin-bottom: 0.5rem; }
.phone-content { font-size: 0.75rem; color: var(--text); }

/* SMS bubble in phone */
.sms-bubble {
    background: var(--bg-elevated);
    border-radius: 10px 10px 10px 2px;
    padding: 0.5rem 0.75rem;
    font-size: 0.72rem;
    color: var(--text);
    line-height: 1.5;
    border: 1px solid var(--border);
    transition: background 0.4s, border-color 0.4s;
}
.sms-bubble.outdated { border-color: rgba(248,113,113,0.4); background: var(--red-muted); }
.sms-bubble.updated  { border-color: rgba(52,211,153,0.4);  background: var(--green-muted); }
```

---

## Contribution Bar

```css
.contribution-bar {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    padding: 1rem 1.5rem;
    border-radius: var(--radius-lg);
    background: linear-gradient(135deg, rgba(96,165,250,0.08), rgba(167,139,250,0.08));
    border: 1px solid rgba(96,165,250,0.2);
    margin: 1.5rem 0;
}
.contribution-icon { font-size: 1.2rem; }
.contribution-text { font-size: 0.9rem; color: var(--text); font-weight: 500; text-align: center; }
```

---

## Footer

```css
.footer {
    text-align: center;
    padding: 2rem 0 1rem;
    font-size: 0.75rem;
    color: var(--text-dim);
    letter-spacing: 0.5px;
}
```

---

## Keyframe Animations

```css
@keyframes softPulse {
    0%, 100% { opacity: 1; }
    50%       { opacity: 0.7; }
}

@keyframes shimmer {
    0%   { background-position: 0% center; }
    100% { background-position: 200% center; }
}

@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(12px); }
    to   { opacity: 1; transform: translateY(0); }
}

@keyframes pulseDown {
    0%   { top: 0;    opacity: 1; }
    100% { top: 100%; opacity: 0; }
}

@keyframes particle-flow {
    0%   { left: 0%;   opacity: 0; }
    10%  { opacity: 1; }
    90%  { opacity: 1; }
    100% { left: 100%; opacity: 0; }
}

@keyframes shake {
    0%, 100% { transform: translateX(0); }
    20%       { transform: translateX(-6px); }
    40%       { transform: translateX(6px); }
    60%       { transform: translateX(-4px); }
    80%       { transform: translateX(4px); }
}
```

---

## Color Semantics — Quick Reference

| Color | Use for |
|-------|---------|
| `--green` | Success, fixed state, new/correct behavior, benefit |
| `--red` | Error, broken state, old/buggy behavior, problem |
| `--amber` | Warning, transition, critical point in flow |
| `--blue` | Active/selected, neutral information, fix-in-progress |
| `--purple` | Auto-play, secondary action, accent |
| `--cyan` | Title gradient accent only |
| `--text-muted` | Labels, subtitles, step numbers |

---

## UI Mockup Panel

> Use when `UI_MOCKUP_MODE = true` — the screenshot shows a real system screen with data counters, field values, or a button that locks/unlocks.

```css
/* ─── UI Mockup Panel ────────────────────────────────────── */
.ui-mockup-wrap { margin-bottom: 1.5rem; animation: fadeInUp 0.35s ease; }
.ui-mockup-wrap.hidden { display: none; }

.mockup-eyebrow {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 0.6rem;
}
.mockup-eyebrow-badge {
    font-size: 0.62rem;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 0.25rem 0.75rem;
    border-radius: var(--radius-full);
    background: var(--blue-muted);
    color: var(--blue);
    border: 1px solid rgba(96,165,250,0.3);
}
.mockup-eyebrow-desc { font-size: 0.75rem; color: var(--text-dim); }

.ui-mockup-panel {
    display: flex;
    align-items: center;
    gap: 1rem;
    flex-wrap: wrap;
    padding: 1.25rem 1.5rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--mockup-bg);
    transition: border-color 0.4s, box-shadow 0.4s;
}
.ui-mockup-panel.panel-locked {
    border-color: rgba(248, 113, 113, 0.45);
    box-shadow: 0 0 24px rgba(248, 113, 113, 0.12);
}
.ui-mockup-panel.panel-ok {
    border-color: rgba(52, 211, 153, 0.45);
    box-shadow: 0 0 24px rgba(52, 211, 153, 0.12);
}

.mockup-col {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 80px;
}
.mockup-label-text {
    font-size: 0.62rem;
    font-weight: 700;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: var(--text-dim);
    margin-bottom: 0.2rem;
}
.mockup-value {
    font-size: 1.6rem;
    font-weight: 800;
    font-variant-numeric: tabular-nums;
    line-height: 1;
    transition: color 0.3s;
}
.mockup-v-blue  { color: var(--blue); }
.mockup-v-green { color: var(--green); }
.mockup-v-red   { color: var(--red); }
.mockup-v-amber { color: var(--amber); }

.mockup-value.flash { animation: valueFlash 0.45s ease; }

.mockup-annotation {
    font-size: 0.62rem;
    color: var(--text-dim);
    margin-top: 0.2rem;
    text-align: center;
    min-height: 0.9rem;
}

/* Vertical separator between field groups */
.mockup-sep {
    width: 1px;
    height: 60px;
    background: var(--border-light);
    flex-shrink: 0;
    margin: 0 0.25rem;
}

/* Action button inside the mockup panel */
.mockup-btn-wrap { display: flex; align-items: center; }
.mockup-send-btn {
    padding: 0.6rem 1.1rem;
    border-radius: var(--radius-md);
    background: var(--green);
    color: #0d1425;
    font-size: 0.78rem;
    font-weight: 700;
    cursor: pointer;
    transition: opacity 0.3s, background 0.3s, color 0.3s, box-shadow 0.3s;
    white-space: nowrap;
}
.mockup-send-btn.btn-locked {
    background: var(--red-muted);
    color: var(--red);
    cursor: not-allowed;
    box-shadow: 0 0 14px var(--red-glow);
}

/* Status bar at the bottom of the mockup */
.mockup-status {
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    padding: 0.75rem 1.25rem;
    border-radius: 0 0 var(--radius-lg) var(--radius-lg);
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-top: none;
    font-size: 0.78rem;
    color: var(--text-muted);
    transition: all 0.3s;
}
.mockup-status.status-locked {
    background: var(--red-muted);
    color: var(--red);
    border-color: rgba(248, 113, 113, 0.3);
}
.mockup-status.status-ok {
    background: var(--green-muted);
    color: var(--green);
    border-color: rgba(52, 211, 153, 0.3);
}

@keyframes valueFlash {
    0%   { opacity: 1; transform: scale(1); }
    30%  { opacity: 0.4; transform: scale(1.15); }
    60%  { opacity: 1; transform: scale(0.95); }
    100% { opacity: 1; transform: scale(1); }
}
```
| `--text-dim` | Placeholders, inactive states, footer |
