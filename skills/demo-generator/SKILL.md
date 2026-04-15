---
name: demo-generator
description: Generates interactive sprint demo presentations (HTML/CSS/JS) from Technical Design Documents. Use when the user asks for a sprint demo, wants to present changes to non-technical stakeholders, or mentions sprint review preparation.
---

# Sprint Demo Generator

## When to use this skill

Activate when the user wants to:
- Generate an interactive demo for a sprint review ceremony
- Present changes to non-technical stakeholders (product owners, managers, business analysts)
- Visualize a bug fix, new feature, or process change in an interactive, engaging way
- Create a self-running presentation that can be opened directly in a browser

## Role & Persona

Act as a **Senior Frontend Engineer with UX and Presentation expertise**.
- Translate technical changes into clear, visual, interactive stories.
- Target audience: non-technical stakeholders who use the product, not engineers.
- Every demo must answer three questions a business stakeholder cares about:
  > **What was the problem? Why did it hurt us? What is better now?**

## Workflow

Copy this checklist and track progress:
```
Demo Generation Progress:
- [ ] Phase 0: Input & Context
- [ ] Phase 1: Content Extraction
- [ ] Phase 2: Demo Design
- [ ] Phase 3: Generate Files
- [ ] Phase 4: Validation
```

---

## Phase 0: Input & Context

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root (`git rev-parse --show-toplevel`).

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
     5. What is the business impact? (errors reduced, process improved, risk eliminated?)
     ```

4. **Check for existing demo:**
   ```bash
   find <workspace_root>/ai/<ISSUE_KEY>/demo -name "index.html" 2>/dev/null
   ```
   **IF found:** Ask: `"A demo already exists for <ISSUE_KEY>. Regenerate from scratch or update?"`

5. **Ask about screenshots:**
   > "Do you have any screenshots to include in the demo? (before/after UI screenshots, error screens, browser captures — any image is fine)"

   - **IF screenshots provided:**
     - Note them as `SCREENSHOT_BEFORE` and/or `SCREENSHOT_AFTER`.
     - Ask: `"Are these before/after pairs, or screenshots of the new UI only?"`
     - Then ask: **"Does the screenshot show a live system screen with data counters, status fields, or a button that locks/unlocks?** (e.g., a table showing counts, a 'Send' button that is grayed out)"
       - **IF YES** → Set `UI_MOCKUP_MODE = true`. This screen will be recreated as interactive HTML elements — NOT embedded as a static image. The screenshot is only used as a **visual reference** to understand the layout and field names.
       - **IF NO** → `UI_MOCKUP_MODE = false`. Use the static Slider/Gallery path (Step D below).
   - **IF no screenshots:** Continue without them. Both the screenshot section and UI Mockup Panel are omitted.

---

## Phase 1: Content Extraction

From the document or user input, extract and transform these fields:

| Field | What to Extract | Rule |
|-------|----------------|------|
| **Title** | Feature or fix name | Rewrite without jargon |
| **Subtitle** | One-line description | Must be understandable by a non-technical person |
| **Problem** | The "before" state | Use analogy or concrete example |
| **Business Impact** | Why it mattered | Prefer measurable: "every 10 transactions", "notification lost" |
| **Solution** | What was changed | Describe the effect, never the implementation |
| **Flow Steps** | Steps to demonstrate | Named as user actions or visible events, not code calls |
| **Contribution** | Benefit to team/product | 1 sentence: "Bu geliştirme ... sağlar" |
| **Screenshots** | Image file paths provided by user | Copy to `demo/screenshots/` relative folder; reference with relative path `./screenshots/<filename>` |

### Non-technical language rewrite rules

> [!CAUTION]
> **NEVER expose technical terms in demo-visible text.** If it requires software knowledge to understand, rewrite it.

| Technical Term | Non-technical Replacement |
|----------------|--------------------------|
| NullPointerException, error, exception | "Sistem beklenmedik bir durumla karşılaşıyordu" |
| Trace ID mismatch | "Bildirimin başı ve sonu birbirini tanımıyordu" |
| policyRef / foreign key | "Yanlış kayıt seçiliyordu" |
| Strategy Pattern | "Sistem artık otomatik olarak doğru yolu seçiyor" |
| Async job / scheduled task | "İlerideki tarihte gönderilmek üzere bekleyen işlem" |
| API / endpoint / service | "servis", "bağlantı noktası", "iletişim kanalı" |
| Repository / database | "kayıt sistemi", "veri tabanı" |
| null / undefined | "eksik bilgi", "doldurulmamış alan" |
| Bug / defect | "sorun", "hata durumu" |
| Deploy / release | "sisteme alındı", "yayına çıktı" |
| Refactor | "iyileştirme" || Cache | "geçici hafıza", "önbellek" (explain on first use) |
| Queue / Kafka | "sıra", "işlem kuyruğu" |
| Worker / consumer | "arka planda çalışan işlem" |
| Retry | "yeniden deneme" |
| Rollback | "geri alma" |

### Concrete example rule

> [!IMPORTANT]
> Every "Neden Önemli?" card MUST contain a **real-world analogy or scenario** that a non-technical person can picture immediately. Abstract impact statements alone are not enough.

Good example:
> *"7/24 Acil Destek numaramız değiştiğinde, eski numara şablonda kalırsa; kaza yapan bir müşteri eski numarayı arayıp ulaşamadığında, bu sadece bir hata değil, hayati bir risk ve büyük bir güven krizidir."*

Bad example (too abstract):
> *"Veri tutarsızlığı operasyonel risklere yol açabilir."*
---

## Phase 2: Demo Design

### Step A: Select layout type

Choose the layout based on what the issue demonstrates. See [references/LAYOUTS.md](references/LAYOUTS.md) for structure details.

| Condition | Layout |
|-----------|--------|
| A single process flow that had a bug — show how it broke and how it is fixed | **PIPELINE** |
| Multiple independent bug fixes in one issue — each needs its own explanation | **TABS_BEFORE_AFTER** |
| A new feature that routes differently based on a condition (company, type, etc.) | **BRANCH_FLOW** |
| A change the user can interact with (type input, click a button, see result on screen) | **INTERACTIVE_SIMULATION** |
| A simple single change with clear before/after | **PIPELINE** (2-scenario variant without NORMAL) |

### Step B: Select header style

| Condition | Header Style |
|-----------|--------------|
| Sprint review ceremony, non-technical audience, broad visibility | **HERO** — full-width background gradient, large centered title, badge at top |
| Technical team demo, quick sync, 1:1 walkthrough | **STANDARD** — compact header with badge, title, subtitle (current default) |

**HERO header structure:**
```html
<header class="hero">
    <div class="hero-badge">SPRINT REVIEW: [CATEGORY]</div>
    <h1 class="hero-title">[Non-technical Title]</h1>
    <p class="hero-subtitle">[One question: "[Problem] neden oluyordu ve bunu nasıl çözdük?"]</p>
</header>
```
Where `[CATEGORY]` is one of: `TEKNİK İYİLEŞTİRME` / `YENİ ÖZELLİK` / `HATA DÜZELTMESİ` / `PERFORMANS`

### Step B: Define scenarios

**PIPELINE** — always 3 buttons:
- **Normal Akış** (green): Happy path, everything works correctly
- **Sorunlu Akış** (red): The bug / old broken behavior
- **Düzeltilmiş Akış** (blue): The fixed/new behavior

**TABS_BEFORE_AFTER** — one tab per fix:
- Tab label: short non-technical fix title
- Each tab: Before toggle (red) and After toggle (green)

**BRANCH_FLOW** — one button per flow path:
- Button per condition (e.g., per company, per type)
- Each path shows its own animated flow steps

### Step C: Plan all demo sections

Every demo MUST include all of these sections, in this order:

| # | Section | Required | Description |
|---|---------|----------|-------------|
| 1 | **Header** | Always | Standard or HERO style (chosen in Step B) |
| 2 | **Why/What/Benefit cards** | Always | 3 horizontal cards: "Neden Önemli?", "Çözüm Nedir?", "Takıma Faydası" |
| 3 | **Navigation** | Always | Scenario buttons/tabs + step counter (layout-specific) |
| 4 | **Main Visual** | Always | The chosen layout with animated steps/flow |
| 4a | **UI Mockup Panel** | When `UI_MOCKUP_MODE = true` | Interactive HTML recreation of the real system screen; values (counters, button states) update dynamically when scenario/phase changes. Placed immediately after Main Visual. |
| 5 | **System Logs** | INTERACTIVE_SIMULATION only | Console-style log box showing state changes in real time |
| 6 | **Phone/Screen Mockup** | When end result is customer-facing | Shows what the customer actually sees on their device |
| 7 | **Screenshot Section** | When `UI_MOCKUP_MODE = false` and user provides screenshots | Before/after image comparison or gallery with lightbox |
| 8 | **Info Panel** | Always | Narrative text that updates with each step, plain language |
| 9 | **Impact Section** | Always | Side-by-side: "Önceki Durum" (red) vs "Yeni Durum" (green) |
| 9 | **Summary Cards** | Always | "SORUN" card (red) + "ÇÖZÜM" card (green) |
| 10 | **Contribution Bar** | Always | One sentence: how this change helps team/product/company |
| 11 | **Footer** | Always | `Sprint Demo • Title • Year` |

**Why/What/Benefit card structure:**
```html
<div class="why-section">
    <div class="why-card why-problem">
        <div class="why-icon">⚠️</div>
        <h3>1. Neden Önemli?</h3>
        <p>[Business impact in plain language]</p>
        <div class="why-example">[Concrete real-world analogy or scenario]</div>
    </div>
    <div class="why-card why-solution">
        <div class="why-icon">✅</div>
        <h3>2. Çözüm Nedir?</h3>
        <ul>
            <li>[Plain-language change 1]</li>
            <li>[Plain-language change 2]</li>
        </ul>
    </div>
    <div class="why-card why-benefit">
        <div class="why-icon">📈</div>
        <h3>3. Takıma Faydası</h3>
        <ul class="benefit-list">
            <li><span class="check">✓</span> [Benefit 1]</li>
            <li><span class="check">✓</span> [Benefit 2]</li>
            <li><span class="check">✓</span> [Benefit 3]</li>
        </ul>
    </div>
</div>
```

**System Logs structure (INTERACTIVE_SIMULATION only):**
```html
<div class="sys-log" id="sysLog">
    <div class="sys-log-header">SİSTEM LOGLARI</div>
    <div class="sys-log-body" id="sysLogBody">
        <span class="log-muted">Simülasyon hazır...</span>
    </div>
</div>
```
Logs are appended via JS: `appendLog('[timestamp] [message]')`

**Phone Mockup structure (customer-facing demos):**
```html
<div class="phone-mockup">
    <div class="phone-notch"></div>
    <div class="phone-screen">
        <div class="phone-label">Müşteri Ekranı</div>
        <div class="phone-content" id="phoneContent">
            <!-- dynamic content -->
        </div>
    </div>
</div>
```

### Step D: Screenshot / UI Mockup section

#### Path A — UI Mockup Panel (`UI_MOCKUP_MODE = true`)

When the screenshot shows a real system screen with **data counters, field values, or a button with a locked/unlocked state**, recreate it as interactive HTML — **do NOT embed the screenshot as a static `<img>`** tag.

**How to extract the mockup fields from the screenshot:**
1. List every visible data field (label + its before/after value)
2. Identify if any field value changes between before and after state
3. Note the presence of an action button and whether it is locked/grayed in the before state
4. Note any status bar or explanation message at the bottom

**UI Mockup Panel HTML structure:**

```html
<!-- UI Mockup Panel — shown after Main Visual, initially hidden -->
<div class="ui-mockup-wrap hidden" id="uiMockupWrap">
    <div class="mockup-eyebrow">
        <div class="mockup-eyebrow-badge">🖥 GERÇEK SİSTEM EKRANI</div>
        <div class="mockup-eyebrow-desc">Bu panel sistemin nasıl göründüğünü yansıtır — değerler seçilen senaryoya göre güncellenir</div>
    </div>
    <div class="ui-mockup-panel" id="uiMockupPanel">
        <!-- One mockup-col per data field -->
        <div class="mockup-col">
            <div class="mockup-label-text">[Field Label]</div>
            <div class="mockup-value mockup-v-blue" id="mField1">—</div>
            <div class="mockup-annotation" id="mField1Note"></div>
        </div>
        <div class="mockup-col">
            <div class="mockup-label-text">[Field Label]</div>
            <div class="mockup-value mockup-v-green" id="mField2">—</div>
            <div class="mockup-annotation" id="mField2Note"></div>
        </div>
        <!-- Add more columns for each field; use mockup-v-red for error metrics, mockup-v-amber for warning counts -->
        <div class="mockup-sep"></div>
        <!-- Action button -->
        <div class="mockup-btn-wrap">
            <div class="mockup-send-btn" id="mActionBtn">[Button Label]</div>
        </div>
    </div>
    <div class="mockup-status" id="mockupStatus">
        <span id="mockupStatusIcon">⏳</span>
        <span id="mockupStatusText">Senaryo bekleniyor...</span>
    </div>
</div>
```

**Value color classes:**

| Class | Color | Use for |
|-------|-------|---------|
| `mockup-v-blue` | Blue | Neutral numeric totals |
| `mockup-v-green` | Green | Success/completed counts |
| `mockup-v-red` | Red | Failed/error counts |
| `mockup-v-amber` | Amber | Pending/in-progress counts you want to highlight |

**JS data shape — add a `mockup` object to each `BUGS[n]` entry:**

```js
mockup: {
    before: {
        field1: '[value in broken state]',
        field1Note: '⚠ [optional annotation explaining the problem]',
        field2: '[value]',
        field2Note: '',
        // ... repeat for each field
        btnLocked: true,
        btnText: '🔒 [Locked button label]',
        statusClass: 'status-locked',
        statusIcon: '🔒',
        statusText: '[Plain-language explanation of why the system is stuck in this state]'
    },
    after: {
        field1: '[value in fixed state]',
        field1Note: '',
        field2: '[value]',
        field2Note: '',
        btnLocked: false,
        btnText: '[Normal unlocked button label]',
        statusClass: 'status-ok',
        statusIcon: '✅',
        statusText: '[Plain-language explanation of why the system is now working correctly]'
    }
}
```

**`updateMockupPanel()` function — call this from `selectBug()` and `showPhase()`:**

```js
function updateMockupPanel(bugId, phase) {
    var wrap = document.getElementById('uiMockupWrap');
    if (!wrap) return;
    var data = BUGS[bugId].mockup[phase];

    // Reveal the panel on first call
    wrap.classList.remove('hidden');

    // Update each data field
    flashValue('mField1', data.field1);
    document.getElementById('mField1Note').textContent = data.field1Note;
    flashValue('mField2', data.field2);
    document.getElementById('mField2Note').textContent = data.field2Note;
    // ... repeat for each field

    // Update action button state
    var btn = document.getElementById('mActionBtn');
    btn.textContent = data.btnText;
    btn.className = 'mockup-send-btn' + (data.btnLocked ? ' btn-locked' : '');

    // Update panel border (locked = red glow, ok = green glow)
    document.getElementById('uiMockupPanel').className =
        'ui-mockup-panel ' + (data.btnLocked ? 'panel-locked' : 'panel-ok');

    // Update status bar
    var status = document.getElementById('mockupStatus');
    status.className = 'mockup-status ' + data.statusClass;
    document.getElementById('mockupStatusIcon').textContent = data.statusIcon;
    document.getElementById('mockupStatusText').textContent = data.statusText;
}

function flashValue(id, newVal) {
    var el = document.getElementById(id);
    if (!el) return;
    el.textContent = newVal;
    el.classList.remove('flash');
    void el.offsetWidth;          // force reflow to restart animation
    el.classList.add('flash');
}
```

> [!IMPORTANT]
> The screenshot is **reference only** — used to understand field names and layout. Do not embed it with `<img>` when `UI_MOCKUP_MODE = true`. All visible UI elements must be real HTML that updates dynamically.

---

#### Path B — Static Screenshot (`UI_MOCKUP_MODE = false`)

**When user provides screenshots**, add a section between the Main Visual and Info Panel.

**Decision:**
- **IF both before AND after screenshots provided:** Use the **Before/After Slider** — a drag divider that reveals the before image on the left and after image on the right.
- **IF only after screenshot(s) provided:** Use the **Gallery** mode — clickable cards that open a lightbox overlay.
- **IF 3+ screenshots provided:** Always use Gallery mode regardless.

**Before/After Slider markup:**
```html
<div class="screenshot-section">
    <div class="ss-title">📸 Ekran Görüntüleri</div>
    <div class="ss-slider-container">
        <div class="ss-label ss-label-before">⚠️ Önceki</div>
        <div class="ss-label ss-label-after">✅ Yeni</div>
        <div class="ss-before" style="width: 50%">
            <img src="./screenshots/before.png" alt="Önceki durum" draggable="false">
        </div>
        <div class="ss-after">
            <img src="./screenshots/after.png" alt="Yeni durum" draggable="false">
        </div>
        <div class="ss-divider" id="ssDivider">
            <div class="ss-handle">⇔</div>
        </div>
    </div>
</div>
```

**Gallery markup (lightbox):**
```html
<div class="screenshot-section">
    <div class="ss-title">📸 Ekran Görüntüleri</div>
    <div class="ss-gallery">
        <div class="ss-card" onclick="openLightbox('./screenshots/img1.png', 'Açıklama')">
            <img src="./screenshots/img1.png" alt="Açıklama">
            <div class="ss-card-label">Açıklama</div>
        </div>
    </div>
    <!-- Lightbox overlay -->
    <div class="ss-lightbox" id="ssLightbox" onclick="closeLightbox()">
        <div class="ss-lightbox-inner">
            <img id="ssLightboxImg" src="" alt="">
            <div class="ss-lightbox-caption" id="ssLightboxCaption"></div>
            <button class="ss-lightbox-close" onclick="closeLightbox()">✕</button>
        </div>
    </div>
</div>
```

**Screenshot file handling:**
> [!IMPORTANT]
> Do NOT embed screenshots as base64. Always copy the file to `demo/screenshots/<filename>` and reference with a relative `./screenshots/<filename>` path. If the user provides an absolute path, instruct them to copy the file or use the path directly.

---

### Step E: Plan auto-play and keyboard support

Every demo MUST include:
- **▶ Otomatik Oynat / ⏸ Duraklat** toggle: starts auto-advancing steps at 1400ms intervals
- **Keyboard support:**
  - `ArrowRight` or `Space` → advance to next step
  - `ArrowLeft` → go to previous step
  - `R` → reset current scenario
- **Step counter:** shows `Adım: 2 / 5` in the navigation area

### Step F: INTERACTIVE_SIMULATION specifics

> Use when the user can directly manipulate an input and see the change propagate through the system visually.

Required elements beyond standard:
- **Input form** on the left: a textarea or input + a primary action button (`Kaydet`, `Gönder`, etc.)
- **Central flow diagram**: nodes connected with animated arrows representing data movement (DB → Cache → Customer)
- **Phone/screen mockup** on the right: shows the customer-facing result
- **System logs**: timestamped output showing each action in sequence
- **Scenario toggle**: a 2-state toggle button (`Eski Yapı (Sorunlu)` / `Yeni Çözüm (Düzeltildi)`) — NOT multiple scenario buttons
- **Behavior difference**: in the "Sorunlu" state, the flow shows data going stale (old value shown to customer despite update); in the "Düzeltilmiş" state, the cache is invalidated and the customer sees the new value immediately

---

## Phase 3: Generate Files

Output directory:
```
<workspace_root>/ai/<ISSUE_KEY>/demo/
├── index.html
├── style.css
└── app.js
```

### index.html

Full HTML structure. See [references/LAYOUTS.md](references/LAYOUTS.md) for layout-specific markup.

**Required base structure:**
```html
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Non-technical Title] — Sprint Demo</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="theme-dark">
    <!-- Theme toggle — fixed top-right -->
    <button class="theme-toggle" id="themeToggle" onclick="toggleTheme()" title="Tema değiştir">
        <span id="themeIcon">☀️</span>
    </button>

    <div class="app">
        <header class="header">
            <div class="header-badge">SPRINT DEMO</div>
            <h1 class="header-title">[Title]</h1>
            <p class="header-subtitle">[Subtitle — non-technical]</p>
        </header>

        <!-- Navigation (layout-specific) -->

        <!-- Main Visual (layout-specific) -->

        <!-- UI Mockup Panel (only when UI_MOCKUP_MODE = true — interactive HTML recreation of system screen) -->
        <!-- <div class="ui-mockup-wrap hidden" id="uiMockupWrap"> ... </div> -->

        <!-- Screenshot Section (only when UI_MOCKUP_MODE = false and user provides screenshots) -->
        <!-- <div class="screenshot-section"> ... </div> -->

        <!-- Info Panel -->
        <div class="info-panel" id="infoPanel">
            <div class="info-header">
                <span class="info-icon" id="infoIcon">ℹ️</span>
                <span class="info-title" id="infoTitle">Nasıl Çalışır?</span>
            </div>
            <div class="info-body" id="infoBody">[Default explanation]</div>
        </div>

        <!-- Impact Section -->
        <div class="impact-section">
            <div class="impact-card impact-before">
                <div class="impact-label">⚠️ Önceki Durum</div>
                <ul class="impact-list" id="impactBefore">
                    <!-- populated from JS -->
                </ul>
            </div>
            <div class="impact-arrow">→</div>
            <div class="impact-card impact-after">
                <div class="impact-label">✅ Yeni Durum</div>
                <ul class="impact-list" id="impactAfter">
                    <!-- populated from JS -->
                </ul>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="summary-section">
            <div class="summary-card summary-problem">
                <div class="summary-header">
                    <span class="summary-icon">🐛</span>
                    <span>SORUN</span>
                </div>
                <div class="summary-body">[Plain-language problem description]</div>
            </div>
            <div class="summary-card summary-solution">
                <div class="summary-header">
                    <span class="summary-icon">✅</span>
                    <span>ÇÖZÜM</span>
                </div>
                <div class="summary-body">[Plain-language solution description]</div>
            </div>
        </div>

        <!-- Contribution Bar -->
        <div class="contribution-bar">
            <span class="contribution-icon">🚀</span>
            <span class="contribution-text">[One sentence: team/product/company benefit]</span>
        </div>

        <footer class="footer">
            <p>Sprint Demo • [Title] • [Year]</p>
        </footer>
    </div>
    <script src="app.js"></script>
</body>
</html>
```

### style.css

See [assets/design-system.md](assets/design-system.md) for the full CSS variable palette and component reference.

**Non-negotiable rules:**
- CSS variables defined in `:root` (dark default) and `body.theme-light` (light override) — never hardcode colors
- `font-family: var(--font)` everywhere
- `background: var(--bg)` on `body`
- `max-width: 1100px; margin: 0 auto; padding: 2rem 2.5rem` on `.app` — sized for 720p (1280×720) displays
- Theme toggle button: `position: fixed; top: 1rem; right: 1rem; z-index: 1000`
- Mobile breakpoint at `640px` for navigation and main visual
- Include `@keyframes` for: `softPulse`, `shimmer`, `fadeInUp`, `particle-flow`
- When `UI_MOCKUP_MODE = true`, include UI Mockup CSS from [assets/design-system.md](assets/design-system.md): `--mockup-bg` variable, `.ui-mockup-wrap`, `.ui-mockup-panel`, `.mockup-col`, `.mockup-value` color variants, `.mockup-status`, `.btn-locked`, `@keyframes valueFlash`
- See [assets/design-system.md](assets/design-system.md) for light theme variables, theme toggle CSS, and screenshot section CSS

### app.js

**Non-negotiable rules:**
- Vanilla JS only — zero external libraries or CDN imports
- State machine: `activeScenario`, `currentStep`, `totalSteps`, `autoPlayInterval`
- `resetAll()` function: clears timers, removes active classes, resets info panel
- Auto-play: `toggleAutoPlay()` using `setInterval` at 1400ms
- Keyboard handler registered on `document.addEventListener('keydown', ...)`
- Impact section: populate `#impactBefore` and `#impactAfter` lists dynamically on scenario selection
- Theme: read saved preference from `localStorage.getItem('theme')` on load; default to `'dark'`
- Screenshots (if present): Before/After Slider uses `mousedown`/`mousemove`/`mouseup` + `touchstart`/`touchmove`/`touchend` for drag; lightbox uses `openLightbox(src, caption)` / `closeLightbox()` functions

**Required global state:**
```js
let activeScenario = null;
let currentStep = 0;
let totalSteps = 0;
let autoPlayInterval = null;
let currentTheme = localStorage.getItem('theme') || 'dark';

const IMPACT = {
  before: [/* plain-language bullet strings */],
  after:  [/* plain-language bullet strings */]
};

// Apply saved theme on page load — sets class on body
document.body.className = 'theme-' + currentTheme;
updateThemeIcon();

function toggleTheme() {
    currentTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.body.className = 'theme-' + currentTheme;
    localStorage.setItem('theme', currentTheme);
    updateThemeIcon();
}

function updateThemeIcon() {
    document.getElementById('themeIcon').textContent = currentTheme === 'dark' ? '☀️' : '🌙';
}
```

> [!NOTE]
> When `UI_MOCKUP_MODE = true` (TABS_BEFORE_AFTER layout), add `BUGS[n].mockup.before/after` data and call `updateMockupPanel(bugId, phase)` from both `selectBug()` and `showPhase()`. See Step D for the full data shape and function implementation.

---

## Phase 4: Validation

### Non-technical language check

Read every visible text string in the generated HTML and JS data objects. Fail if any of these appear:
- Class names, method names, or variable names visible to users
- Technical acronyms not explained (API is acceptable only if in context)
- Any sentence that requires software knowledge to understand
- Impact/problem description with no concrete example ("this causes errors" alone is insufficient)

### Completeness check

- [ ] All 3 files created in correct directory
- [ ] `index.html` valid HTML5, opens without console errors
- [ ] `<body class="theme-dark">` present on page load
- [ ] Theme toggle button visible and switches dark ↔ light correctly
- [ ] Theme preference persisted in `localStorage`
- [ ] Light theme: all text readable, no invisible text on white background
- [ ] `.app` max-width is `1100px`, padding `2rem 2.5rem`
- [ ] Header style matches chosen type (STANDARD or HERO)
- [ ] Why/What/Benefit 3-card section present and non-technical
- [ ] "Neden Önemli?" card contains a concrete real-world example
- [ ] Main visual renders correctly for chosen layout
- [ ] System logs present if INTERACTIVE_SIMULATION layout
- [ ] Phone mockup present if customer-facing result
- [ ] Screenshot section present and functional if `UI_MOCKUP_MODE = false` and screenshots provided
- [ ] Before/After slider drag works (mouse + touch) if 2 screenshots provided
- [ ] Lightbox opens/closes correctly if gallery mode
- [ ] If `UI_MOCKUP_MODE = true`: UI Mockup Panel is hidden initially; appears after first bug/scenario selection
- [ ] If `UI_MOCKUP_MODE = true`: all field values update when switching between before/after phases
- [ ] If `UI_MOCKUP_MODE = true`: button locked/unlocked state reflected visually (`.btn-locked` class + label)
- [ ] If `UI_MOCKUP_MODE = true`: panel border changes (red glow = locked, green glow = ok)
- [ ] If `UI_MOCKUP_MODE = true`: status bar text and icon update with each phase
- [ ] If `UI_MOCKUP_MODE = true`: `flashValue()` animation plays on every value change
- [ ] If `UI_MOCKUP_MODE = true`: no raw field names, technical IDs, or code identifiers visible in the UI
- [ ] Impact section has at least 2 bullets per side
- [ ] Summary cards have non-technical text
- [ ] Contribution bar has one sentence
- [ ] Auto-play button starts/stops correctly
- [ ] Keyboard navigation works (ArrowRight, ArrowLeft, R)
- [ ] `resetAll()` fully restores initial state
- [ ] Responsive at 640px viewport

### Output summary

```
✅ Demo Generated

Issue:   <ISSUE_KEY>
Layout:  <PIPELINE | TABS_BEFORE_AFTER | BRANCH_FLOW>

Files:
  - <workspace_root>/ai/<ISSUE_KEY>/demo/index.html
  - <workspace_root>/ai/<ISSUE_KEY>/demo/style.css
  - <workspace_root>/ai/<ISSUE_KEY>/demo/app.js

Open: open <workspace_root>/ai/<ISSUE_KEY>/demo/index.html
```

---

## Quick reference

### Layout selection

| Issue type | Layout | Header |
|------------|--------|--------|
| Single process bug | PIPELINE | STANDARD |
| Multiple independent bugs | TABS_BEFORE_AFTER | STANDARD |
| New feature with branching/routing | BRANCH_FLOW | STANDARD |
| User-operable simulation (cache, form, send) | INTERACTIVE_SIMULATION | HERO |
| Sprint ceremony, broad non-technical audience | any | HERO |

### Required sections (all mandatory)

| Section | Key requirement |
|---------|----------------|
| Theme toggle | Fixed top-right, persists in localStorage, dark default (`body.theme-dark`) |
| Header | STANDARD badge or HERO full-width gradient |
| Why/What/Benefit cards | 3 cards, concrete example in "Neden Önemli?" |
| Navigation | Scenario controls + step counter |
| Main visual | Animated, interactive, layout-specific |
| UI Mockup Panel | `UI_MOCKUP_MODE = true` only — interactive HTML recreation of real system screen; field values + button state driven by JS; NOT a static `<img>` |
| System logs | INTERACTIVE_SIMULATION only — timestamped |
| Phone mockup | Customer-facing demos only |
| Screenshot section | `UI_MOCKUP_MODE = false` only — Slider (2 images) or Gallery (1 or 3+) |
| Info panel | Updates on every step, plain language |
| Impact section | Before vs After, bullet lists |
| Summary cards | Problem (red) + Solution (green) |
| Contribution bar | 1-sentence team/product benefit |
| Footer | Sprint Demo • Title • Year |

### Language rules

- All user-visible text: **Turkish**
- Code identifiers (HTML IDs, JS variables, CSS class names): **English**
- Technical terms in text: **forbidden** — always rewrite

---

## Tone & Style

- **Non-technical first.** If a non-software person cannot explain what they see, rewrite it.
- **Visual storytelling.** Show the problem before you show the solution.
- **Measurable impact.** Prefer concrete over vague: "her 10 işlemden 1'inde hata" vs "arada bir hata".
- **Positive framing.** Focus on what is now possible, not just what was broken.
- **Consistent design.** Always use the design system — no deviations in colors or fonts.
