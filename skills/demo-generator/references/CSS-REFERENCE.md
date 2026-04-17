# CSS Reference

Complete CSS variable system and shared component styles for all demos. Issue-specific hero visual CSS is documented in [HERO-VISUALS.md](HERO-VISUALS.md).

---

## CSS Variables — Dark Theme (Default)

```css
:root {
    --bg:           #060b18;
    --bg-card:      #0d1425;
    --bg-elevated:  #131c33;
    --bg-surface:   #1a2540;

    --border:       #1e2d4a;
    --border-light: #2a3f65;

    --text:         #e0e7f1;
    --text-muted:   #7b8fad;
    --text-heading: #f0f4f8;
    --text-dim:     #4a5f80;

    --green:        #34d399;
    --green-glow:   rgba(52, 211, 153, 0.28);
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
    --purple-glow:  rgba(167, 139, 250, 0.20);

    --cyan:         #22d3ee;

    --radius-sm:   6px;
    --radius-md:   12px;
    --radius-lg:   16px;
    --radius-xl:   24px;
    --radius-full: 9999px;

    --font:      'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    --font-mono: 'Courier New', 'Menlo', monospace;
}
```

---

## Light Theme Override

```css
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
}

body.theme-light::before {
    background:
        radial-gradient(ellipse at 20% 15%, rgba(96, 165, 250, 0.07) 0%, transparent 55%),
        radial-gradient(ellipse at 80% 85%, rgba(52, 211, 153, 0.05) 0%, transparent 55%);
}

body.theme-light .topnav {
    background: rgba(240, 244, 248, 0.90);
}
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

body::before {
    content: '';
    position: fixed;
    inset: 0;
    background:
        radial-gradient(ellipse at 20% 10%, rgba(96, 165, 250, 0.06) 0%, transparent 50%),
        radial-gradient(ellipse at 80% 90%, rgba(52, 211, 153, 0.04) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 50%, rgba(167, 139, 250, 0.03) 0%, transparent 60%);
    pointer-events: none;
    z-index: 0;
}
```

---

## Top Navigation

```css
.topnav {
    position: sticky;
    top: 0;
    z-index: 100;
    background: rgba(6, 11, 24, 0.88);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid var(--border);
}

.nav-inner {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0.75rem 2.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.nav-badge {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.75rem;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    color: var(--text-muted);
}

.nav-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--green);
    animation: blink 2s ease-in-out infinite;
}

/* Nav state toggle */
.nav-state-toggle {
    display: inline-flex;
    background: var(--bg-elevated);
    border: 1px solid var(--border);
    border-radius: var(--radius-full);
    padding: 3px;
    gap: 3px;
}

.nstbtn {
    padding: 0.3rem 0.85rem;
    border-radius: var(--radius-full);
    border: none;
    background: transparent;
    color: var(--text-muted);
    font-size: 0.72rem;
    font-weight: 700;
    font-family: var(--font);
    cursor: pointer;
    transition: all 0.22s ease;
    white-space: nowrap;
    letter-spacing: 0.2px;
}

.nstbtn.active { color: #fff; }

.nstbtn-before.active {
    background: linear-gradient(135deg, #b91c1c, #d97706);
    box-shadow: 0 0 10px var(--red-glow);
}

.nstbtn-after.active {
    background: linear-gradient(135deg, #059669, #0891b2);
    box-shadow: 0 0 10px var(--green-glow);
}

/* Theme toggle */
.theme-toggle {
    width: 38px;
    height: 38px;
    border-radius: var(--radius-full);
    border: 1.5px solid var(--border-light);
    background: var(--bg-card);
    font-size: 0.95rem;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    box-shadow: 0 2px 8px rgba(0,0,0,0.3);
}

.theme-toggle:hover {
    transform: scale(1.1);
    border-color: var(--blue);
    box-shadow: 0 0 14px var(--blue-glow);
}
```

---

## Section Shell (shared by Story, Root Cause, Impact)

```css
.sec-inner {
    position: relative;
    z-index: 1;
    max-width: 1200px;
    margin: 0 auto;
    padding: 6rem 2.5rem;
}

.sec-eyebrow {
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--blue);
    margin-bottom: 0.75rem;
}

.sec-title {
    font-size: clamp(1.75rem, 3.5vw, 2.6rem);
    font-weight: 800;
    color: var(--text-heading);
    letter-spacing: -0.5px;
    line-height: 1.15;
    margin-bottom: 1.25rem;
}

.sec-sub {
    font-size: 1rem;
    color: var(--text-muted);
    max-width: 680px;
    line-height: 1.7;
    margin-bottom: 3rem;
}
```

---

## Hero Section

```css
.section-hero {
    position: relative;
    z-index: 1;
    min-height: calc(100vh - 60px);
    display: flex;
    align-items: center;
}

.hero-layout {
    max-width: 1200px;
    margin: 0 auto;
    padding: 5rem 2.5rem;
    display: grid;
    grid-template-columns: 1fr 420px;  /* Adjust right column for visual type */
    gap: 4rem;
    align-items: center;
}

.eyebrow {
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--text-dim);
    margin-bottom: 1rem;
}

.hero-title {
    font-size: clamp(2rem, 4vw, 3.2rem);
    font-weight: 900;
    line-height: 1.1;
    letter-spacing: -1px;
    color: var(--text-heading);
    margin-bottom: 1.25rem;
}

.title-accent {
    background: linear-gradient(135deg, var(--red) 0%, var(--amber) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    transition: all 0.6s ease;
}

.title-accent.fixed {
    background: linear-gradient(135deg, var(--green) 0%, var(--cyan) 100%);
    -webkit-background-clip: text;
    background-clip: text;
}

.hero-sub {
    font-size: 1.05rem;
    color: var(--text-muted);
    line-height: 1.7;
    max-width: 480px;
    margin-bottom: 2rem;
}

/* Silent callout */
.silent-callout {
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
    padding: 0.65rem 1rem;
    background: var(--amber-muted);
    border: 1px solid rgba(251, 191, 36, 0.2);
    border-radius: var(--radius-md);
    max-width: 440px;
    transition: all 0.4s ease;
}

.silent-callout.callout-good {
    background: var(--green-muted);
    border-color: rgba(52, 211, 153, 0.25);
}

.sc-icon { font-size: 1.1rem; flex-shrink: 0; margin-top: 0.05rem; }

.sc-text {
    font-size: 0.8rem;
    color: var(--amber);
    line-height: 1.4;
    transition: color 0.4s;
}

.callout-good .sc-text { color: var(--green); }

.hero-visual {
    display: flex;
    justify-content: center;
    align-items: center;
}
```

---

## Story Section

```css
.section-story {
    position: relative;
    z-index: 1;
    border-top: 1px solid var(--border);
}

.story-track {
    display: flex;
    align-items: stretch;
    gap: 0;
    margin-top: 1rem;
}

.sstep {
    flex: 1;
    padding: 2rem 1.5rem;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-xl);
    display: flex;
    flex-direction: column;
    gap: 1rem;
    transition: all 0.3s;
}

.sstep:hover {
    transform: translateY(-3px);
    border-color: var(--border-light);
}

.sstep-num {
    font-size: 0.65rem;
    font-weight: 800;
    letter-spacing: 2px;
    color: var(--text-dim);
}

.sstep-icon-wrap {
    width: 52px;
    height: 52px;
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.6rem;
}

.sstep-ok   { background: var(--green-muted); }
.sstep-warn { background: var(--amber-muted); }
.sstep-bad  { background: var(--red-muted);   }
.sstep-good { background: var(--green-muted); }

.sstep-content h3 {
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text-heading);
    margin-bottom: 0.4rem;
}

.sstep-content p {
    font-size: 0.82rem;
    color: var(--text-muted);
    line-height: 1.6;
}

.sstep-content p strong { color: var(--text); }

.sstep-connector {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 0.5rem;
    min-width: 40px;
    flex-shrink: 0;
}

.sconn-arrow {
    font-size: 1.6rem;
    color: var(--text-dim);
    font-weight: 300;
}
```

---

## Impact Section (Before/After + Contribution)

```css
.section-impact {
    position: relative;
    z-index: 1;
    border-top: 1px solid var(--border);
}

.ba-grid {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 1.5rem;
    align-items: stretch;
    margin-bottom: 3rem;
}

.ba-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-xl);
    padding: 2rem;
}

.ba-before { border-top: 3px solid var(--red);   }
.ba-after  { border-top: 3px solid var(--green); }

.ba-header { margin-bottom: 1.25rem; }

.ba-badge {
    display: inline-block;
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 0.3rem 0.75rem;
    border-radius: var(--radius-full);
}

.ba-badge-before { background: var(--red-muted);   color: var(--red);   }
.ba-badge-after  { background: var(--green-muted); color: var(--green); }

.ba-list {
    list-style: none;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.65rem;
}

.ba-list li {
    display: flex;
    gap: 0.6rem;
    align-items: flex-start;
    font-size: 0.85rem;
    color: var(--text-muted);
    line-height: 1.5;
}

.ba-before .ba-list li::before { content: '✕'; color: var(--red);   flex-shrink: 0; font-weight: 700; }
.ba-after  .ba-list li::before { content: '✓'; color: var(--green); flex-shrink: 0; font-weight: 700; }

.ba-transform {
    display: flex;
    align-items: center;
    justify-content: center;
}

.ba-transform-arrow {
    font-size: 2rem;
    color: var(--text-dim);
    font-weight: 300;
}

/* Contribution bar */
.contribution {
    display: flex;
    align-items: flex-start;
    gap: 1.25rem;
    padding: 1.5rem 2rem;
    background: linear-gradient(135deg, var(--bg-elevated), var(--bg-surface));
    border: 1px solid var(--border-light);
    border-radius: var(--radius-xl);
}

.contrib-icon { font-size: 1.8rem; flex-shrink: 0; margin-top: 0.1rem; }

.contrib-text {
    font-size: 0.95rem;
    color: var(--text);
    line-height: 1.65;
}
```

---

## Scroll Reveal Animation

```css
.reveal {
    opacity: 0;
    transform: translateY(20px);
    transition: opacity 0.55s ease, transform 0.55s ease;
}

.reveal.visible {
    opacity: 1;
    transform: translateY(0);
}
```

---

## Footer

```css
.footer {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 1.5rem 2rem;
    border-top: 1px solid var(--border);
    font-size: 0.72rem;
    color: var(--text-dim);
}
```

---

## Utility Classes

```css
.hidden { display: none !important; }
```

---

## Keyframes

```css
@keyframes blink {
    0%, 100% { opacity: 1; }
    50%       { opacity: 0.3; }
}

@keyframes fixPulse {
    0%   { transform: scale(1);    }
    40%  { transform: scale(1.15); }
    100% { transform: scale(1);    }
}

@keyframes valueReveal {
    0%   { opacity: 0; transform: translateY(4px) scale(0.95); }
    60%  { opacity: 1; transform: translateY(-1px) scale(1.05); }
    100% { opacity: 1; transform: translateY(0) scale(1); }
}

@keyframes countFlash {
    0%   { transform: scale(1);    filter: brightness(1); }
    40%  { transform: scale(1.25); filter: brightness(1.5); }
    100% { transform: scale(1);    filter: brightness(1); }
}

@keyframes btnPulse {
    0%, 100% { box-shadow: 0 0 20px rgba(59, 130, 246, 0.35); }
    50%       { box-shadow: 0 0 30px rgba(59, 130, 246, 0.60); }
}

@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0);    }
}
```

---

## Mobile Breakpoint (640-720px)

```css
@media (max-width: 720px) {
    .nav-inner  { padding: 0.75rem 1rem; }
    .sec-inner  { padding: 3.5rem 1.25rem; }

    .hero-layout {
        grid-template-columns: 1fr;
        padding: 3rem 1.25rem;
        gap: 2.5rem;
    }

    .hero-visual { order: -1; }

    .story-track { flex-direction: column; gap: 1rem; }
    .sstep-connector { flex-direction: row; min-width: auto; }

    .ba-grid {
        grid-template-columns: 1fr;
        gap: 1rem;
    }

    .ba-transform { display: none; }
}
```

---

## Hero Layout Grid Sizes by Visual Type

| Visual Type | Right Column | Notes |
|-------------|-------------|-------|
| Phone Mockup | `420px` | Narrower — phone is compact |
| System Panel | `520px` | Wider — panel has stat columns |
| Timeline | `420px` | Medium — vertical layout |
