# Demo Generator — Layout Reference

Detailed HTML structure and JavaScript patterns for each of the 4 supported layout types.

---

## PIPELINE

**When to use:** A single end-to-end process that was broken and is now fixed. Best for trace/flow bugs, sequential processing errors.

**Scenario buttons:** Normal Akış (green) | Sorunlu Akış (red) | Düzeltilmiş Akış (blue) | Sıfırla

**Structure:**
```html
<div class="controls">
    <button class="btn btn-normal"  id="btnNormal"  onclick="startScenario('NORMAL')">
        <span>✅</span> Normal Akış
    </button>
    <button class="btn btn-problem" id="btnProblem" onclick="startScenario('PROBLEM')">
        <span>🐛</span> Sorunlu Akış (Eski)
    </button>
    <button class="btn btn-fix"     id="btnFix"     onclick="startScenario('FIX')">
        <span>🔧</span> Düzeltilmiş Akış (Yeni)
    </button>
    <button class="btn btn-reset"   onclick="resetAll()">
        <span>↺</span> Sıfırla
    </button>
    <button class="btn btn-autoplay" id="btnAutoplay" onclick="toggleAutoPlay()">
        <span id="autoplayIcon">▶</span>
        <span id="autoplayLabel">Otomatik Oynat</span>
    </button>
    <span class="step-counter" id="stepCounter">Adım: — / —</span>
</div>

<div class="scenario-banner" id="scenarioBanner">
    <span id="scenarioBannerIcon">📋</span>
    <span id="scenarioBannerText">Bir senaryo seçerek demo akışını başlatın</span>
</div>

<div class="pipeline" id="pipeline">
    <div class="pipe-step"      id="ps1">...</div>
    <div class="pipe-connector" id="conn1">
        <div class="connector-line">
            <div class="connector-pulse" id="pulse1"></div>
        </div>
        <div class="connector-badge" id="connBadge1"></div>
    </div>
    <div class="pipe-step"      id="ps2">...</div>
    <!-- repeat for N steps -->
</div>
```

**JS data shape:**
```js
var SCENARIOS = {
    NORMAL: {
        banner: { icon: '✅', text: 'Normal Akış — ...' },
        bannerClass: 'banner-normal',
        infoClass: 'info-green',
        steps: [
            {
                show: 'ps1',
                connector: null,         // null for first step
                glow: 'glow-green',
                pulse: { id: 'pulse1', cls: 'pulse-green' },
                connLine: { id: null, cls: 'line-green' },
                connBadge: null,         // { id, text, cls } when needed
                detail: { id: 'detail1', text: '...', cls: 'detail-green' },
                info: { icon: '✅', title: 'Adım 1: ...', body: 'HTML string ...' },
                shake: false             // true to shake the node (error moment)
            }
            // ...more steps
        ]
    },
    PROBLEM: { /* same shape, red glow, broken connLine */ },
    FIX:     { /* same shape, blue glow, shows fix overlay */ }
};
```

**Key JS functions required:**
```js
function startScenario(type) { ... }   // set active scenario, run steps
function runSteps(steps, index) { ... } // setTimeout chain
function activateStep(step, cb) { ... } // apply DOM changes for one step
function resetAll() { ... }            // clear all timeouts, remove classes
function toggleAutoPlay() { ... }      // setInterval / clearInterval at 1400ms
function updateStepCounter(cur, total) { ... }
```

---

## TABS_BEFORE_AFTER

**When to use:** Multiple independent fixes in one issue (3+ unrelated bugs). Each requires its own before/after explanation.

**Structure:**
```html
<div class="tab-bar">
    <button class="tab" id="tab1" onclick="selectBug(1)">
        <span class="tab-num">1</span>
        <span class="tab-text">[Short non-technical fix title]</span>
    </button>
    <button class="tab" id="tab2" onclick="selectBug(2)">
        <span class="tab-num">2</span>
        <span class="tab-text">...</span>
    </button>
    <!-- repeat for each fix -->
</div>

<div class="bug-banner" id="bugBanner">
    <div class="bug-banner-icon" id="bugBannerIcon">👆</div>
    <div class="bug-banner-text" id="bugBannerText">Yukarıdan bir senaryo seçin</div>
</div>

<!-- 2-state toggle (not 3 buttons) -->
<div class="toggle-bar" id="toggleBar">
    <button class="toggle-btn toggle-before active" id="toggleBefore" onclick="showPhase('before')">
        🐛 Önceki Durum (Hatalı)
    </button>
    <button class="toggle-btn toggle-after" id="toggleAfter" onclick="showPhase('after')">
        ✅ Yeni Durum (Düzeltilmiş)
    </button>
</div>

<!-- One scene per fix -->
<div class="bug-scene" id="scene1">
    <div class="phase phase-before" id="scene1Before">
        <div class="flow-visual">
            <!-- fv-step, fv-arrow, fv-card nodes for broken flow -->
        </div>
    </div>
    <div class="phase phase-after hidden" id="scene1After">
        <div class="flow-visual">
            <!-- fv-step, fv-arrow, fv-card nodes for fixed flow -->
        </div>
    </div>
</div>
<div class="bug-scene hidden" id="scene2"> ... </div>
```

**JS data shape:**
```js
var BUGS = {
    1: {
        banner: { icon: '🔧', text: '[Plain-language description of fix 1]' },
        before: { /* flow node data */ },
        after:  { /* flow node data */ },
        impactBefore: ['bullet 1', 'bullet 2'],
        impactAfter:  ['bullet 1', 'bullet 2']
    },
    2: { ... }
};

var activeBug = null;
var activePhase = 'before';

function selectBug(n) { ... }       // show scene N, update banner, populate impact
function showPhase(phase) { ... }   // toggle before/after visibility
function animateScene(sceneId) { ... } // fadeInUp on cards
```

**CSS additions:**
```css
.tab-bar { display: flex; gap: 0.5rem; flex-wrap: wrap; margin-bottom: 1rem; }
.tab {
    display: flex; align-items: center; gap: 0.5rem;
    padding: 0.5rem 1rem;
    border: 1.5px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--bg-card);
    color: var(--text-muted);
    font-size: 0.8rem; font-weight: 600;
    cursor: pointer; transition: all 0.2s;
    font-family: var(--font);
}
.tab.active, .tab:hover {
    border-color: var(--blue); color: var(--blue);
    background: var(--blue-muted);
}
.tab-num {
    width: 20px; height: 20px;
    border-radius: 50%;
    background: var(--bg-elevated);
    display: flex; align-items: center; justify-content: center;
    font-size: 0.7rem; font-weight: 700;
}

.phase { animation: fadeInUp 0.3s ease; }
.phase.hidden { display: none; }
.bug-scene.hidden { display: none; }

.flow-visual {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    flex-wrap: wrap;
    padding: 1.5rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
    min-height: 160px;
}
.fv-arrow { display: flex; align-items: center; }
.fv-arrow-line { width: 32px; height: 2px; background: var(--border-light); position: relative; }
.fv-arrow-line::after { content: '▶'; position: absolute; right: -8px; top: -7px; font-size: 0.6rem; color: var(--border-light); }
```

---

## BRANCH_FLOW

**When to use:** A new feature that routes/dispatches differently based on a dynamic condition (company, type, tier). Shows how the system picks the right path automatically.

**Buttons:** One per branch (e.g., "AGESA Senaryosu", "MEDISA Senaryosu") + Sıfırla

**Structure:**
```html
<div class="controls">
    <button class="btn btn-branch-a" id="btnA" onclick="startFlow('A')">
        <span>🏢</span> [Branch A Label]
    </button>
    <button class="btn btn-branch-b" id="btnB" onclick="startFlow('B')">
        <span>🏥</span> [Branch B Label]
    </button>
    <button class="btn btn-reset" onclick="resetFlow()">↺ Sıfırla</button>
</div>

<div class="flow-container">
    <!-- Shared steps (before the branch point) -->
    <div class="flow-step" id="step1"> ... </div>
    <div class="flow-arrow" id="arrow1"> ... </div>
    <div class="flow-step" id="step2"> ... </div>
    <div class="flow-arrow" id="arrow2"> ... </div>
    <div class="flow-step" id="step3"> ... </div>  <!-- decision node -->

    <!-- Branch fork -->
    <div class="flow-branch" id="branchContainer">
        <div class="branch branch-left" id="branchA">
            <div class="branch-arrow" id="arrowA"> ... </div>
            <div class="flow-step"> <div class="step-card card-a" id="step4A"> ... </div> </div>
        </div>
        <div class="branch branch-right" id="branchB">
            <div class="branch-arrow" id="arrowB"> ... </div>
            <div class="flow-step"> <div class="step-card card-b" id="step4B"> ... </div> </div>
        </div>
    </div>

    <!-- Converge back to shared result -->
    <div class="flow-step" id="step5"> ... </div>
</div>
```

**JS data shape:**
```js
const FLOW_STEPS = {
    A: {
        company: 'A',
        color: 'branch-a',
        steps: [
            {
                target: 'step1',
                arrow: 'arrow1',
                particle: 'particle1',
                detail: { id: 'step1Detail', text: '...' },
                info: { title: '1️⃣ ...', body: '...' }
            },
            // ...
            {
                target: 'branchA',    // branch-specific step
                arrow: 'arrowA',
                particle: 'particleA',
                branch: 'A'           // activates only this branch visual
            }
        ]
    },
    B: { /* same shape */ }
};
```

**CSS additions:**
```css
.flow-container { display: flex; flex-direction: column; align-items: center; gap: 0; }
.flow-step { width: 100%; max-width: 440px; }
.step-card {
    padding: 1rem 1.25rem;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    background: var(--bg-card);
    display: flex; align-items: flex-start; gap: 1rem;
    opacity: 0; transform: scale(0.97);
    transition: opacity 0.35s, transform 0.35s, border-color 0.3s, box-shadow 0.3s;
}
.step-card.visible { opacity: 1; transform: scale(1); }

.flow-branch {
    display: flex; gap: 2rem;
    justify-content: center;
    width: 100%; max-width: 640px;
    margin: 0.5rem 0;
}
.branch { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; flex: 1; }
.step-card.active-branch {
    border-color: var(--blue);
    box-shadow: 0 0 20px var(--blue-glow);
}
.step-card.dimmed { opacity: 0.35; }
```

---

## INTERACTIVE_SIMULATION

**When to use:** The demo shows a user action (editing a field, clicking save/send) and the resulting data flow, with a visible customer-facing outcome. Best for cache bugs, form submission issues, data propagation.

**Header style:** Always HERO.

**Toggle:** 2-state only (`Eski Yapı (Sorunlu)` / `Yeni Çözüm (Düzeltildi)`), NOT multiple scenario buttons.

**Structure:**
```html
<!-- Scenario toggle -->
<div style="text-align:center; margin-bottom:1.5rem;">
    <div class="scenario-toggle">
        <button class="toggle-btn active-problem" id="toggleProblem" onclick="setScenario('problem')">
            🐛 Eski Yapı (Sorunlu)
        </button>
        <button class="toggle-btn" id="toggleFix" onclick="setScenario('fix')">
            ✅ Yeni Çözüm (Düzeltildi)
        </button>
    </div>
</div>

<!-- 3-column simulation layout -->
<div class="sim-layout">

    <!-- Left: User input -->
    <div class="sim-panel sim-input">
        <div class="sim-panel-title">✏️ 1. [Entity] Düzenle</div>
        <div class="sim-panel-desc">[What the user is trying to do]</div>
        <textarea id="simInput" class="sim-textarea">[Default old value]</textarea>
        <button class="sim-btn sim-btn-save" onclick="doSave()">
            💾 [Kaydet / Güncelle]
        </button>
        <div class="sim-panel-divider"></div>
        <div class="sim-panel-title">➤ 2. [Action] Yap</div>
        <div class="sim-panel-desc">[What this triggers]</div>
        <button class="sim-btn sim-btn-send" onclick="doSend()">
            📤 [Gönder / Uygula]
        </button>
        <!-- Inline system log -->
        <div class="sys-log" style="margin-top:1rem;">
            <div class="sys-log-header">SİSTEM LOGLARI</div>
            <div class="sys-log-body" id="sysLogBody">
                <span class="log-muted">Simülasyon hazır...</span>
            </div>
        </div>
    </div>

    <!-- Center: Data flow diagram -->
    <div class="sim-panel sim-flow">
        <div class="sim-flow-node" id="nodeDB">
            <div class="sfn-icon">🗄️</div>
            <div class="sfn-label">Veritabanı (DB)</div>
            <div class="sfn-sub">Kalıcı Kayıt</div>
            <div class="sfn-value" id="dbValue">—</div>
        </div>
        <div class="sim-flow-arrow" id="arrowDBtoCache">↓</div>
        <div class="sim-flow-node" id="nodeCache">
            <div class="sfn-icon">⚡</div>
            <div class="sfn-label">[Cache / Geçici Hafıza]</div>
            <div class="sfn-sub">Hızlı Erişim</div>
            <div class="sfn-value" id="cacheValue">—</div>
            <div class="sfn-state" id="cacheState"></div>
        </div>
        <div class="sim-flow-arrow" id="arrowCacheToPhone">→</div>
    </div>

    <!-- Right: Customer view -->
    <div class="sim-panel sim-phone">
        <div class="phone-mockup">
            <div class="phone-notch"></div>
            <div class="phone-screen">
                <div class="phone-label">Müşteri Ekranı</div>
                <div class="phone-content" id="phoneContent">
                    <div class="sms-bubble" id="smsBubble">[Initial content]</div>
                </div>
            </div>
        </div>
    </div>

</div>
```

**CSS additions:**
```css
.sim-layout {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 1rem;
    align-items: start;
    margin-bottom: 1.5rem;
}
@media (max-width: 640px) { .sim-layout { grid-template-columns: 1fr; } }

.sim-panel {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 1.25rem;
}
.sim-panel-title { font-size: 0.82rem; font-weight: 700; color: var(--text-heading); margin-bottom: 0.25rem; }
.sim-panel-desc  { font-size: 0.75rem; color: var(--text-muted); margin-bottom: 0.75rem; }
.sim-panel-divider { height: 1px; background: var(--border); margin: 1rem 0; }

.sim-textarea {
    width: 100%;
    padding: 0.6rem 0.75rem;
    border-radius: var(--radius-sm);
    border: 1px solid var(--border-light);
    background: var(--bg-elevated);
    color: var(--text);
    font-family: var(--font);
    font-size: 0.82rem;
    resize: vertical;
    min-height: 70px;
    margin-bottom: 0.75rem;
}
.sim-btn {
    width: 100%;
    padding: 0.65rem;
    border-radius: var(--radius-md);
    border: none;
    font-family: var(--font);
    font-size: 0.82rem;
    font-weight: 600;
    cursor: pointer;
    transition: opacity 0.2s;
}
.sim-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.sim-btn-save { background: var(--blue); color: #fff; }
.sim-btn-send { background: var(--green); color: #111; }

/* Flow diagram nodes */
.sim-flow { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem; }
.sim-flow-node {
    width: 100%;
    padding: 0.85rem 1rem;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    background: var(--bg-elevated);
    text-align: center;
    transition: border-color 0.3s, box-shadow 0.3s;
}
.sim-flow-node.node-active-ok   { border-color: var(--green); box-shadow: 0 0 16px var(--green-glow); }
.sim-flow-node.node-active-warn { border-color: var(--amber); box-shadow: 0 0 16px var(--amber-glow); }
.sim-flow-node.node-active-err  { border-color: var(--red);   box-shadow: 0 0 16px var(--red-glow); }
.sfn-icon  { font-size: 1.2rem; }
.sfn-label { font-size: 0.75rem; font-weight: 700; color: var(--text-heading); }
.sfn-sub   { font-size: 0.65rem; color: var(--text-muted); }
.sfn-value { font-size: 0.72rem; color: var(--cyan); font-family: 'Courier New', monospace; margin-top: 0.25rem; min-height: 1em; }
.sfn-state { font-size: 0.65rem; margin-top: 0.2rem; }

.sim-flow-arrow { font-size: 1.2rem; color: var(--text-dim); }

/* Phone positioning */
.sim-phone { display: flex; justify-content: center; }
```

**JS pattern:**
```js
let scenario = 'problem';   // 'problem' | 'fix'
let saveState = null;       // what was saved to DB

function setScenario(s) {
    scenario = s;
    resetSim();
    document.getElementById('toggleProblem').classList.toggle('active-problem', s === 'problem');
    document.getElementById('toggleFix').classList.toggle('active-fix', s === 'fix');
}

function doSave() {
    const val = document.getElementById('simInput').value.trim();
    saveState = val;
    appendLog(`[${ts()}] Veritabanına kaydedildi: "${val}"`);
    // Animate DB node
    pulse('nodeDB', 'node-active-ok');
    document.getElementById('dbValue').textContent = val;

    if (scenario === 'fix') {
        // Cache invalidated immediately
        appendLog(`[${ts()}] Önbellek temizlendi (invalidate).`, 'log-warn');
        pulse('nodeCache', 'node-active-warn');
        document.getElementById('cacheValue').textContent = '(Boş / Geçersiz)';
        document.getElementById('cacheState').textContent = '♻️ Temizlendi';
    } else {
        // Cache NOT invalidated — old value remains
        appendLog(`[${ts()}] Önbellek güncellenmedi — eski değer kalıyor.`, 'log-error');
    }
}

function doSend() {
    if (!saveState) { appendLog(`[${ts()}] Önce kaydedin!`, 'log-warn'); return; }

    if (scenario === 'problem') {
        // Cache hit with old value
        appendLog(`[${ts()}] Önbellekten okundu — ESKİ değer.`, 'log-error');
        pulse('nodeCache', 'node-active-err');
        document.getElementById('smsBubble').textContent = '[Old value from cache]';
        document.getElementById('smsBubble').className = 'sms-bubble outdated';
    } else {
        // Cache miss → DB read → fresh value
        appendLog(`[${ts()}] Önbellekte veri yok → Veritabanından okundu.`, 'log-success');
        pulse('nodeCache', 'node-active-ok');
        document.getElementById('cacheValue').textContent = saveState;
        document.getElementById('smsBubble').textContent = saveState;
        document.getElementById('smsBubble').className = 'sms-bubble updated';
    }
}

function appendLog(msg, cls = 'log-success') {
    const body = document.getElementById('sysLogBody');
    const line = document.createElement('div');
    line.className = cls;
    line.textContent = msg;
    body.appendChild(line);
    body.scrollTop = body.scrollHeight;
}

function pulse(nodeId, cls) {
    const el = document.getElementById(nodeId);
    el.classList.add(cls);
    setTimeout(() => el.classList.remove(cls), 1800);
}

function ts() {
    return new Date().toLocaleTimeString('tr-TR');
}

function resetSim() {
    saveState = null;
    document.getElementById('sysLogBody').innerHTML = '<span class="log-muted">Simülasyon hazır...</span>';
    document.getElementById('dbValue').textContent = '—';
    document.getElementById('cacheValue').textContent = '—';
    document.getElementById('cacheState').textContent = '';
    document.getElementById('smsBubble').textContent = '[Müşteri içeriği burada görünür]';
    document.getElementById('smsBubble').className = 'sms-bubble';
    ['nodeDB','nodeCache'].forEach(id => {
        const el = document.getElementById(id);
        ['node-active-ok','node-active-warn','node-active-err'].forEach(c => el.classList.remove(c));
    });
}
```

---

## UI MOCKUP PANEL (Cross-Layout Feature)

> This is **not a separate layout** — it is an enhancement layer that can be added to any layout (most commonly TABS_BEFORE_AFTER) when `UI_MOCKUP_MODE = true`.

**When to use:** The screenshot provided by the user shows a real system screen containing:
- Data counters or numeric field values (e.g., "Toplam: 8", "Tamamlanan: 4")
- A button whose state changes between before/after (locked → unlocked, grayed → active)
- A status message that explains the current system state

**Core decision:**
```
Screenshot shows data fields / button states?
  YES → UI Mockup Panel (HTML recreation, values driven by JS)
  NO  → Static Screenshot (Slider or Gallery in Step D of SKILL.md)
```

**Never embed the screenshot as `<img>` when `UI_MOCKUP_MODE = true`.** The screenshot is used only as a reference to understand the field layout and label names.

---

### HTML Structure

Place this block immediately after the Main Visual and before the Info Panel:

```html
<!-- UI Mockup Panel — initially hidden, revealed on first bug/scenario selection -->
<div class="ui-mockup-wrap hidden" id="uiMockupWrap">
    <div class="mockup-eyebrow">
        <div class="mockup-eyebrow-badge">🖥 GERÇEK SİSTEM EKRANI</div>
        <div class="mockup-eyebrow-desc">Bu panel sistemin nasıl göründüğünü yansıtır — değerler seçilen senaryoya göre güncellenir</div>
    </div>

    <div class="ui-mockup-panel" id="uiMockupPanel">
        <!-- One .mockup-col per data field visible in the screenshot -->
        <div class="mockup-col">
            <div class="mockup-label-text">Toplam</div>
            <div class="mockup-value mockup-v-blue" id="mTotal">—</div>
            <div class="mockup-annotation" id="mTotalNote"></div>
        </div>
        <div class="mockup-col">
            <div class="mockup-label-text">Tamamlanan</div>
            <div class="mockup-value mockup-v-green" id="mSuccess">—</div>
            <div class="mockup-annotation" id="mSuccessNote"></div>
        </div>
        <div class="mockup-col">
            <div class="mockup-label-text">Başarısız</div>
            <div class="mockup-value mockup-v-red" id="mFailed">—</div>
            <div class="mockup-annotation" id="mFailedNote"></div>
        </div>
        <div class="mockup-col">
            <div class="mockup-label-text">Devam Eden</div>
            <div class="mockup-value mockup-v-amber" id="mContinue">—</div>
            <div class="mockup-annotation" id="mContinueNote"></div>
        </div>

        <div class="mockup-sep"></div>

        <!-- The change-subject button (locked in before, unlocked in after) -->
        <div class="mockup-btn-wrap">
            <div class="mockup-send-btn" id="mActionBtn">Bildirim Gönder</div>
        </div>
    </div>

    <div class="mockup-status" id="mockupStatus">
        <span id="mockupStatusIcon">⏳</span>
        <span id="mockupStatusText">Senaryo bekleniyor...</span>
    </div>
</div>
```

> Add or remove `.mockup-col` blocks to match the actual fields visible in the screenshot. Adjust `mockup-v-*` color classes to reflect the semantic meaning of each field.

---

### JS Data Shape

Add a `mockup` key to each entry in `BUGS`:

```js
var BUGS = {
    1: {
        banner:  { ... },
        info:    { before: { ... }, after: { ... } },
        impactBefore: [...],
        impactAfter:  [...],

        // ── UI Mockup data ──────────────────────────────────
        mockup: {
            before: {
                total:       '8',
                totalNote:   '⚠ 4 kişi için 8 kayıt (2× fazla)',
                success:     '4',
                successNote: '',
                failed:      '0',
                failedNote:  '',
                continueVal: '4',
                continueNote:'⚠ Hiç sıfırlanamaz ∞',

                btnLocked:   true,
                btnText:     '🔒 Kilitli — İşlem Devam Ediyor',

                statusClass: 'status-locked',
                statusIcon:  '🔒',
                statusText:  '[Plain-language explanation of why the system is stuck]'
            },
            after: {
                total:       '4',
                totalNote:   '',
                success:     '4',
                successNote: '',
                failed:      '0',
                failedNote:  '',
                continueVal: '--',
                continueNote:'',

                btnLocked:   false,
                btnText:     'Bildirim Gönder',

                statusClass: 'status-ok',
                statusIcon:  '✅',
                statusText:  '[Plain-language explanation of why the system is now working correctly]'
            }
        }
    },
    2: { /* same shape */ }
};
```

---

### JS Functions

Add these functions to `app.js`. Call `updateMockupPanel(n, phase)` from both `selectBug(n)` and `showPhase(phase)`:

```js
/* ─── updateMockupPanel ──────────────────────────────────── */
function updateMockupPanel(bugId, phase) {
    var wrap = document.getElementById('uiMockupWrap');
    if (!wrap) return;
    var data = BUGS[bugId].mockup[phase];

    // Reveal the panel on first call
    wrap.classList.remove('hidden');

    // Update metric values with flash animation
    flashValue('mTotal',        data.total);
    flashValue('mSuccess',      data.success);
    flashValue('mFailed',       data.failed);
    flashValue('mContinue',     data.continueVal);

    // Update annotations
    document.getElementById('mTotalNote').textContent    = data.totalNote;
    document.getElementById('mSuccessNote').textContent  = data.successNote;
    document.getElementById('mFailedNote').textContent   = data.failedNote;
    document.getElementById('mContinueNote').textContent = data.continueNote;

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

/* ─── flashValue ─────────────────────────────────────────── */
function flashValue(id, newVal) {
    var el = document.getElementById(id);
    if (!el) return;
    el.textContent = newVal;
    el.classList.remove('flash');
    void el.offsetWidth;           // force reflow to restart CSS animation
    el.classList.add('flash');
}
```

**Integration points in `selectBug()` and `showPhase()`:**

```js
function selectBug(n) {
    // ... existing logic ...
    updateMockupPanel(n, 'before');
}

function showPhase(phase) {
    // ... existing logic ...
    if (activeBug) updateMockupPanel(activeBug, phase);
}
```

---

### AUTO_PLAY Integration

When `auto_play` cycles through `{ bug, phase }` pairs, `updateMockupPanel` is called indirectly via `selectBug` / `showPhase`. No additional changes needed.

```js
var AUTO_PLAY_SEQUENCE = [
    { bug: 1, phase: 'before' },
    { bug: 1, phase: 'after'  },
    { bug: 2, phase: 'before' },
    { bug: 2, phase: 'after'  }
];
```
