# HTML Structure Reference

This is the full HTML skeleton template that every demo follows. Adapt the hero visual and root cause sections based on the issue type.

---

## Complete HTML Template

```html
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ISSUE_KEY}} — {{Title}} · Sprint Demo</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="theme-dark">

    <!-- ══════════════════════════════════════
         SECTION 1: Top Navigation
    ══════════════════════════════════════ -->
    <nav class="topnav">
        <div class="nav-inner">
            <div class="nav-badge">
                <span class="nav-dot"></span>
                {{ISSUE_KEY}} · {{Category Badge}}
            </div>

            <div class="nav-state-toggle" role="group" aria-label="Durum seçimi">
                <button class="nstbtn nstbtn-before active" id="navBtnBefore" onclick="setState('before')">
                    🐛 Eski Durum
                </button>
                <button class="nstbtn nstbtn-after" id="navBtnAfter" onclick="setState('after')">
                    ✅ Yeni Durum
                </button>
            </div>

            <button class="theme-toggle" id="themeToggle" onclick="toggleTheme()" title="Tema değiştir">
                <span id="themeIcon">☀️</span>
            </button>
        </div>
    </nav>

    <!-- ══════════════════════════════════════
         SECTION 2: Hero
    ══════════════════════════════════════ -->
    <section class="section-hero">
        <div class="hero-layout">

            <!-- Left: Text -->
            <div class="hero-text">
                <div class="eyebrow">Sprint Demo · {{Month}} {{Year}}</div>
                <h1 class="hero-title">
                    {{Hero Headline Line 1}}
                    <br>
                    <span class="title-accent" id="titleAccent">{{Hero Accent Before}}</span>
                </h1>
                <p class="hero-sub">
                    {{Hero Sub — 2-3 sentences explaining the problem}}
                </p>

                <div class="silent-callout" id="heroCallout">
                    <span class="sc-icon">{{Callout Emoji}}</span>
                    <span class="sc-text" id="heroCalloutText">{{Silent callout text}}</span>
                </div>
            </div>

            <!-- Right: Hero Visual -->
            <!-- INSERT HERO VISUAL HERE — see HERO-VISUALS.md -->

        </div>
    </section>

    <!-- ══════════════════════════════════════
         SECTION 3: Story — "Ne Yaşandı?"
    ══════════════════════════════════════ -->
    <section class="section-story">
        <div class="sec-inner">
            <div class="sec-eyebrow">Ne Yaşandı?</div>
            <h2 class="sec-title">{{Story Section Title}}</h2>

            <div class="story-track">

                <!-- Step 1 -->
                <div class="sstep reveal" data-delay="0">
                    <div class="sstep-num">01</div>
                    <div class="sstep-icon-wrap sstep-ok">{{Step1 Emoji}}</div>
                    <div class="sstep-content">
                        <h3>{{Step 1 Title}}</h3>
                        <p>{{Step 1 Description}}</p>
                    </div>
                </div>

                <div class="sstep-connector reveal" data-delay="100">
                    <div class="sconn-arrow">›</div>
                </div>

                <!-- Step 2 -->
                <div class="sstep reveal" data-delay="200">
                    <div class="sstep-num">02</div>
                    <div class="sstep-icon-wrap sstep-warn">{{Step2 Emoji}}</div>
                    <div class="sstep-content">
                        <h3>{{Step 2 Title}}</h3>
                        <p>{{Step 2 Description}}</p>
                    </div>
                </div>

                <div class="sstep-connector reveal" data-delay="300">
                    <div class="sconn-arrow">›</div>
                </div>

                <!-- Step 3 — this step responds to toggle -->
                <div class="sstep reveal" data-delay="400" id="storyEndCard">
                    <div class="sstep-num">03</div>
                    <div class="sstep-icon-wrap sstep-bad" id="storyEndIcon">{{Step3 Emoji}}</div>
                    <div class="sstep-content">
                        <h3 id="storyEndTitle">{{Step 3 Title (before)}}</h3>
                        <p id="storyEndBody">{{Step 3 Description (before)}}</p>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <!-- ══════════════════════════════════════
         SECTION 4: Root Cause — "Kök Neden"
    ══════════════════════════════════════ -->
    <!-- 
         This section is ISSUE-SPECIFIC. Choose the pattern that best fits:
         
         A) Mismatch Pattern — for field name mismatches, mapping errors
            Uses: .section-mismatch, .mismatch-arena, sender/receiver cards
         
         B) Two-Bug Pattern — for multiple root causes
            Uses: .section-bugs, .bugs-grid, .bug-card with math boxes
         
         C) Two-Path Pattern — for architecture/flow changes
            Uses: .section-rootcause, .path-compare, old vs new flow diagrams
         
         D) Custom — design a new visual that fits the specific issue
         
         See below for each pattern's skeleton.
    -->

    <!-- ══════════════════════════════════════
         SECTION 5: Impact — "Değişim"
    ══════════════════════════════════════ -->
    <section class="section-impact">
        <div class="sec-inner">
            <div class="sec-eyebrow">Değişim</div>
            <h2 class="sec-title">{{Impact Title}}</h2>

            <div class="ba-grid">
                <div class="ba-card ba-before reveal" data-delay="0">
                    <div class="ba-header">
                        <span class="ba-badge ba-badge-before">⚠ Önceki</span>
                    </div>
                    <ul class="ba-list">
                        <li>{{Before point 1}}</li>
                        <li>{{Before point 2}}</li>
                        <li>{{Before point 3}}</li>
                        <li>{{Before point 4}}</li>
                    </ul>
                </div>

                <div class="ba-transform reveal" data-delay="100">
                    <div class="ba-transform-arrow">→</div>
                </div>

                <div class="ba-card ba-after reveal" data-delay="200">
                    <div class="ba-header">
                        <span class="ba-badge ba-badge-after">✅ Şimdi</span>
                    </div>
                    <ul class="ba-list">
                        <li>{{After point 1}}</li>
                        <li>{{After point 2}}</li>
                        <li>{{After point 3}}</li>
                        <li>{{After point 4}}</li>
                    </ul>
                </div>
            </div>

            <!-- Contribution bar -->
            <div class="contribution reveal" data-delay="300">
                <div class="contrib-icon">🚀</div>
                <div class="contrib-text">
                    {{Contribution sentence — concrete, observable business impact}}
                </div>
            </div>

        </div>
    </section>

    <!-- ══════════════════════════════════════
         SECTION 6: Footer
    ══════════════════════════════════════ -->
    <footer class="footer">
        <p>Sprint Demo · {{ISSUE_KEY}} · {{Title}} · {{Month}} {{Year}}</p>
    </footer>

    <script src="app.js"></script>
</body>
</html>
```

---

## Root Cause Section Patterns

### Pattern A: Mismatch (field name mismatch, mapping error)

Used when the problem is a mismatch between what was sent and what was expected.

```html
<section class="section-mismatch">
    <div class="sec-inner">
        <div class="sec-eyebrow">Kök Neden</div>
        <h2 class="sec-title">{{Root Cause Title — analogy preferred}}</h2>
        <p class="sec-sub">{{1-2 sentence explanation}}</p>

        <div class="mismatch-arena">

            <!-- Sender card -->
            <div class="ma-card ma-sender reveal" data-delay="0">
                <div class="mac-eyebrow">
                    <span class="mac-dot mac-dot-green"></span>
                    {{Sender Label}}
                </div>
                <div class="mac-field-label">Alan Adı:</div>
                <div class="mac-field-name">
                    <span class="fn-common">{{common prefix}}</span><span class="fn-diff fn-match" id="fnSenderDiff">{{sender diff}}</span><span class="fn-common">{{common suffix}}</span>
                </div>
                <div class="mac-value">
                    Değer: <strong class="mac-value-num">{{value}}</strong>
                </div>
            </div>

            <!-- Match indicator -->
            <div class="ma-indicator reveal" data-delay="150">
                <div class="mai-symbol" id="maiSymbol">≠</div>
                <div class="mai-label" id="maiLabel">Eşleşme yok</div>
                <div class="mai-arrow" id="maiArrow">↓</div>
                <div class="mai-result" id="maiResult">
                    <span class="mir-bad" id="mirBad">null</span>
                    <span class="mir-good hidden" id="mirGood">{{value}} ✓</span>
                </div>
            </div>

            <!-- Receiver card -->
            <div class="ma-card ma-receiver reveal" data-delay="300">
                <div class="mac-eyebrow" id="maReceiverEyebrow">
                    <span class="mac-dot mac-dot-red" id="macReceiverDot"></span>
                    <span id="maReceiverEyebrowText">{{Receiver Label}}</span>
                </div>
                <div class="mac-field-label">Alan Adı:</div>
                <div class="mac-field-name" id="maReceiverFieldName">
                    <span class="fn-common">{{common prefix}}</span><span class="fn-diff fn-mismatch" id="fnReceiverDiff">{{receiver diff}}</span><span class="fn-common">{{common suffix}}</span>
                </div>
                <div class="mac-status" id="macStatus">
                    <span class="mcs-bad" id="mcsBad">{{Bad status}} ❌</span>
                    <span class="mcs-good hidden" id="mcsGood">{{Good status}} ✅</span>
                </div>
            </div>

        </div>

        <div class="mismatch-callout reveal" data-delay="400">
            <div class="mc-icon">💡</div>
            <div class="mc-body" id="mcBody">
                {{Callout explanation — why this mismatch matters}}
            </div>
        </div>
    </div>
</section>
```

### Pattern B: Two-Bug (multiple root causes)

Used when there are two (or more) distinct bugs contributing to the problem.

```html
<section class="section-bugs">
    <div class="sec-inner">
        <div class="sec-eyebrow">Kök Neden</div>
        <h2 class="sec-title">{{Root Cause Question}}</h2>
        <p class="sec-sub">{{Brief explanation}}</p>

        <div class="bugs-grid">

            <!-- Bug 1 -->
            <div class="bug-card reveal" data-delay="0">
                <div class="bug-num-badge bug-badge-1">Sorun 1</div>
                <h3 class="bug-title">{{Bug 1 Title}}</h3>
                <p class="bug-desc">{{Bug 1 Description}}</p>
                <div class="bug-math-wrap">
                    <div class="bug-math" id="bugMath1">
                        <!-- Math rows showing the calculation -->
                        <div class="bm-row">
                            <span class="bm-label">{{Label}}</span>
                            <span class="bm-val bm-blue">{{Value}}</span>
                        </div>
                        <!-- ... more rows ... -->
                        <div class="bm-sep"></div>
                        <div class="bm-row bm-row-result">
                            <span class="bm-label">Bekleyen</span>
                            <span class="bm-val bm-amber" id="bm1Pending">{{Result}} ⚠</span>
                        </div>
                    </div>
                </div>
                <div class="bug-fix-strip" id="bugFix1">
                    <div class="bfs-label" id="bfsLabel1">Nasıl Düzeltildi?</div>
                    <div class="bfs-body" id="bfsBody1">{{Fix explanation}}</div>
                </div>
            </div>

            <!-- Bug 2 — same structure -->

        </div>

        <!-- Combined equation -->
        <div class="combined-equation reveal" data-delay="300">
            <div class="ceq-title" id="ceqTitle">{{Combined result}}</div>
            <div class="ceq-sub" id="ceqSub">{{Combined explanation}}</div>
        </div>
    </div>
</section>
```

### Pattern C: Two-Path (architecture/flow change)

Used when the solution changes the flow or architecture of a process.

```html
<section class="section-rootcause">
    <div class="sec-inner">
        <div class="sec-eyebrow">Kök Neden</div>
        <h2 class="sec-title">{{Root Cause Title}}</h2>
        <p class="sec-sub">{{Explanation}}</p>

        <div class="path-compare">

            <!-- Old path -->
            <div class="path-card path-bad reveal" data-delay="0" id="pathBad">
                <div class="path-badge path-badge-bad">⚠ Eski Yol</div>
                <h3 class="path-title">{{Old Path Title}}</h3>
                <p class="path-desc">{{Old path description}}</p>
                <div class="path-flow">
                    <!-- Node → Arrow → Node → Arrow → Node flow -->
                    <div class="pf-node pf-node-medisa">
                        <div class="pfn-icon">🏢</div>
                        <div class="pfn-label">{{Source}}</div>
                    </div>
                    <div class="pf-arrow">
                        <div class="pfa-line"></div>
                        <div class="pfa-msg pfa-msg-bad">"{{message}}"</div>
                        <div class="pfa-tip">▶</div>
                    </div>
                    <div class="pf-node pf-node-provider pf-node-bad" id="pfProviderBad">
                        <div class="pfn-icon">📦</div>
                        <div class="pfn-label">{{Middleman}}</div>
                        <div class="pfn-cache" id="pfCacheTag">💾 {{Cache label}}</div>
                    </div>
                    <div class="pf-arrow">
                        <div class="pfa-line"></div>
                        <div class="pfa-tip">▶</div>
                    </div>
                    <div class="pf-node pf-node-customer">
                        <div class="pfn-icon">👤</div>
                        <div class="pfn-label">{{End User}}</div>
                        <div class="pfn-result pfn-result-bad" id="pfResultBad">📧 {{Bad result}}</div>
                    </div>
                </div>
            </div>

            <div class="path-vs reveal" data-delay="100">VS</div>

            <!-- New path -->
            <div class="path-card path-good reveal" data-delay="200" id="pathGood">
                <div class="path-badge path-badge-good">✅ Yeni Yol</div>
                <h3 class="path-title">{{New Path Title}}</h3>
                <p class="path-desc">{{New path description}}</p>
                <div class="path-flow">
                    <!-- Same node structure but with good classes -->
                </div>
            </div>

        </div>

        <!-- Optional: Config change card -->
        <div class="config-card reveal" data-delay="0">
            <div class="config-eyebrow">Yapılandırma Değişikliği</div>
            <div class="config-rows">
                <div class="cfg-row cfg-row-old" id="cfgOld">
                    <div class="cfg-label">Eski Adres</div>
                    <div class="cfg-value cfg-value-bad">{{old config value}}</div>
                    <div class="cfg-desc">{{old config description}}</div>
                </div>
                <div class="cfg-arrow">↓</div>
                <div class="cfg-row cfg-row-new" id="cfgNew">
                    <div class="cfg-label">Yeni Adres</div>
                    <div class="cfg-value cfg-value-good">{{new config value}}</div>
                    <div class="cfg-desc">{{new config description}}</div>
                </div>
            </div>
        </div>
    </div>
</section>
```

---

## Story Step Icon Classes

| Class | Background | Use for |
|-------|-----------|---------|
| `sstep-ok` | Green muted | Normal/successful step |
| `sstep-warn` | Amber muted | Warning/intermediate step |
| `sstep-bad` | Red muted | Failure step (before state) |
| `sstep-good` | Green muted | Success step (after state) |

## Reveal Animation

All elements with class `reveal` use IntersectionObserver for scroll-driven animation. Use `data-delay` attribute (in ms) for staggered appearances:

```html
<div class="reveal" data-delay="0">First element</div>
<div class="reveal" data-delay="100">Second element</div>
<div class="reveal" data-delay="200">Third element</div>
```
