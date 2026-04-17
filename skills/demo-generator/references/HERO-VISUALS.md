# Hero Visual Types — HTML Skeletons & CSS

This reference contains the HTML skeletons, CSS, and toggle behavior for each hero visual type.

---

## 1. Phone Mockup

**When:** Change affects what a mobile customer sees on their device screen.

### HTML Skeleton

```html
<div class="hero-visual">
    <div class="phone-wrap">
        <div class="phone-glow-bg" id="phoneGlowBg"></div>
        <div class="phone-device">
            <div class="phone-notch"></div>
            <div class="phone-screen">

                <!-- Status bar -->
                <div class="ps-statusbar">
                    <span class="ps-time">9:41</span>
                    <span class="ps-icons">
                        <span class="psicon-signal">▲▲▲</span>
                        <span class="psicon-wifi">⬡</span>
                        <span class="psicon-battery">▮▮▮</span>
                    </span>
                </div>

                <!-- Navigation bar -->
                <div class="ps-navbar">
                    <span class="ps-back">‹</span>
                    <span class="ps-nav-title">[Screen Title]</span>
                    <span class="ps-nav-action">⋯</span>
                </div>

                <!-- Content header -->
                <div class="ps-claim-header">
                    <span class="ps-active-badge">AKTİF</span>
                    <span class="ps-claim-num">#[ID]</span>
                    <span class="ps-claim-type">[Type Description]</span>
                </div>

                <div class="ps-sep"></div>

                <!-- Data fields -->
                <div class="ps-fields">
                    <div class="psf-row">
                        <span class="psf-label">[Label]</span>
                        <span class="psf-value">[Value]</span>
                    </div>
                    <!-- ... more rows ... -->

                    <!-- THE KEY FIELD — the one that changes on toggle -->
                    <div class="psf-row psf-row-participation" id="psKeyRow">
                        <div class="psf-part-inner">
                            <span class="psf-label">[Key Field Label]</span>
                            <span class="psf-value psf-part-value" id="psKeyValue">—</span>
                        </div>
                        <div class="psf-part-tooltip" id="psTooltip">
                            [Tooltip explaining why this field was empty]
                        </div>
                    </div>
                </div>

                <!-- Bottom action -->
                <div class="ps-action">
                    <div class="ps-action-btn">[Action Button Text]</div>
                </div>

            </div>
        </div>
        <div class="phone-state-label" id="phoneStateLabel">⚠ ESKİ DURUM</div>
    </div>
</div>
```

### CSS Specific to Phone Mockup

```css
/* Phone screen uses its own light theme regardless of page theme */
:root {
    --phone-bg:           #f2f2f7;
    --phone-screen-bg:    #ffffff;
    --phone-text:         #1c1c1e;
    --phone-text-muted:   #8e8e93;
    --phone-separator:    #e5e5ea;
    --phone-amount-ok:    #1c1c1e;
    --phone-nav-bg:       #f9f9fb;
    --phone-badge-bg:     #eefbf5;
    --phone-badge-color:  #00b96b;
}

.phone-wrap {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
}

.phone-glow-bg {
    position: absolute;
    inset: -30px;
    border-radius: 50%;
    background: radial-gradient(ellipse, var(--red-glow) 0%, transparent 70%);
    transition: background 0.8s ease;
    pointer-events: none;
    z-index: 0;
}

.phone-glow-bg.glow-green {
    background: radial-gradient(ellipse, var(--green-glow) 0%, transparent 70%);
}

.phone-device {
    position: relative;
    z-index: 1;
    width: 240px;
    background: #1a1a1a;
    border-radius: 40px;
    padding: 12px;
    box-shadow:
        0 0 0 1px rgba(255,255,255,0.07),
        0 40px 80px rgba(0,0,0,0.6),
        inset 0 1px 0 rgba(255,255,255,0.08);
}

.phone-notch {
    width: 80px;
    height: 22px;
    background: #1a1a1a;
    border-radius: 0 0 14px 14px;
    margin: 0 auto 0;
    position: relative;
    z-index: 2;
}

.phone-screen {
    background: var(--phone-screen-bg);
    border-radius: 32px;
    overflow: hidden;
    color: var(--phone-text);
    margin-top: -22px;
    padding-top: 22px;
}

/* Status bar, navbar, fields, action — see CSS-REFERENCE.md */

.phone-state-label {
    font-size: 0.65rem;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: var(--red);
    background: var(--red-muted);
    border: 1px solid rgba(248, 113, 113, 0.25);
    padding: 0.3rem 0.85rem;
    border-radius: var(--radius-full);
    transition: all 0.5s ease;
}

.phone-state-label.label-good {
    color: var(--green);
    background: var(--green-muted);
    border-color: rgba(52, 211, 153, 0.25);
}
```

### JS Toggle Pattern

```javascript
function applyPhoneState(state) {
    var isBefore = state === 'before';
    var keyRow   = document.getElementById('psKeyRow');
    var keyValue = document.getElementById('psKeyValue');
    var stateLabel = document.getElementById('phoneStateLabel');
    var glowBg     = document.getElementById('phoneGlowBg');

    if (isBefore) {
        keyRow.classList.remove('state-good');
        keyRow.classList.add('state-bad');
        keyValue.textContent = '—';
        keyValue.classList.remove('value-good');
        keyValue.classList.add('value-bad');
        stateLabel.textContent = '⚠ ESKİ DURUM';
        stateLabel.classList.remove('label-good');
        glowBg.classList.remove('glow-green');
    } else {
        keyRow.classList.remove('state-bad');
        keyRow.classList.add('state-good');
        keyValue.textContent = '…';
        setTimeout(function () {
            keyValue.textContent = '[correct value] ✓';
            keyValue.classList.add('value-good');
            keyValue.style.animation = 'none';
            void keyValue.offsetWidth;
            keyValue.style.animation = 'valueReveal 0.5s ease forwards';
        }, 150);
        stateLabel.textContent = '✓ YENİ DURUM';
        stateLabel.classList.add('label-good');
        glowBg.classList.add('glow-green');
    }
}
```

---

## 2. System Panel Mockup

**When:** Change affects a web admin panel — counters, status indicators, or a button that locks/unlocks.

### HTML Skeleton

```html
<div class="hero-visual">
    <div class="screen-wrap">
        <div class="screen-glow" id="screenGlow"></div>

        <!-- Browser chrome -->
        <div class="screen-chrome">
            <div class="chrome-dots">
                <span class="cdot cdot-red"></span>
                <span class="cdot cdot-amber"></span>
                <span class="cdot cdot-green"></span>
            </div>
            <div class="chrome-url">[app-name] / [page-path]</div>
        </div>

        <!-- System panel -->
        <div class="sys-panel" id="sysPanel">
            <div class="sys-stats">
                <!-- Stat columns — adapt number and labels to the issue -->
                <div class="stat-col">
                    <div class="stat-label">[Stat Label]</div>
                    <div class="stat-value stat-blue" id="statTotal">[value]</div>
                    <div class="stat-note stat-note-bad" id="statTotalNote">[annotation]</div>
                </div>
                <!-- ... more stat-col ... -->
            </div>

            <div class="sys-sep"></div>

            <!-- The button -->
            <div class="sys-btn-wrap">
                <button class="sys-btn sys-btn-locked" id="sysBtn" disabled>
                    <span id="sysBtnIcon">🔒</span>
                    <span id="sysBtnText">[Button Label]</span>
                </button>
                <div class="sys-btn-label" id="sysBtnLabel">[Status description]</div>
            </div>
        </div>

        <div class="screen-state-label" id="screenStateLabel">⚠ ESKİ DURUM · [DETAIL]</div>
    </div>
</div>
```

### CSS Specific to System Panel

```css
.screen-wrap {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
    width: 100%;
}

.screen-glow {
    position: absolute;
    inset: -40px;
    border-radius: 30px;
    background: radial-gradient(ellipse, var(--red-glow) 0%, transparent 65%);
    pointer-events: none;
    z-index: 0;
    transition: background 0.8s ease;
}

.screen-glow.glow-good {
    background: radial-gradient(ellipse, var(--green-glow) 0%, transparent 65%);
}

.screen-chrome {
    position: relative;
    z-index: 1;
    background: var(--bg-elevated);
    border: 1px solid var(--border-light);
    border-bottom: none;
    border-radius: var(--radius-lg) var(--radius-lg) 0 0;
    padding: 0.5rem 1rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

.chrome-dots { display: flex; gap: 5px; flex-shrink: 0; }
.cdot { width: 10px; height: 10px; border-radius: 50%; display: block; }
.cdot-red   { background: #ff5f57; }
.cdot-amber { background: #ffbd2e; }
.cdot-green { background: #28ca41; }

.chrome-url {
    font-size: 0.67rem;
    color: var(--text-dim);
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    padding: 0.2rem 0.75rem;
    flex: 1;
    text-align: center;
}

.sys-panel {
    position: relative;
    z-index: 1;
    background: #0a0f1e;
    border: 1px solid var(--border-light);
    border-top: none;
    border-radius: 0 0 var(--radius-lg) var(--radius-lg);
    padding: 1.5rem;
    transition: border-color 0.5s ease;
}

.sys-panel.panel-good {
    border-color: rgba(52, 211, 153, 0.35);
}

.sys-btn-locked {
    background: #1a2540;
    color: #4a5f80;
    border: 1px solid #2a3f65;
    cursor: not-allowed;
}

.sys-btn-active {
    background: #1d4ed8;
    color: #ffffff;
    cursor: pointer;
    border: 1px solid #3b82f6;
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.35);
    animation: btnPulse 2.5s ease-in-out infinite;
}

.screen-state-label {
    font-size: 0.65rem;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: var(--red);
    background: var(--red-muted);
    border: 1px solid rgba(248, 113, 113, 0.25);
    padding: 0.3rem 0.85rem;
    border-radius: var(--radius-full);
    align-self: center;
    transition: all 0.5s ease;
}

.screen-state-label.label-good {
    color: var(--green);
    background: var(--green-muted);
    border-color: rgba(52, 211, 153, 0.25);
}
```

### JS Toggle Pattern

```javascript
var COUNTER_DATA = {
    before: {
        stat1: { value: 8,  note: '[bad annotation]',   noteClass: 'stat-note-bad'  },
        stat2: { value: 2,  note: '',                    noteClass: ''               },
        // ... per-stat config
    },
    after: {
        stat1: { value: 4,  note: '[good annotation] ✓', noteClass: 'stat-note-good' },
        stat2: { value: 2,  note: '',                     noteClass: ''               },
    }
};

function updateCounters(state) {
    var data = COUNTER_DATA[state];
    Object.keys(data).forEach(function (key) {
        applyCounter('stat' + key, data[key]);
    });
    var panel = document.getElementById('sysPanel');
    panel.classList.toggle('panel-good', state === 'after');
}

function applyCounter(elementId, data) {
    var el     = document.getElementById(elementId);
    var noteEl = document.getElementById(elementId + 'Note');
    el.style.animation = 'none';
    void el.offsetWidth;
    el.style.animation = 'countFlash 0.45s ease forwards';
    el.textContent = data.value;
    if (noteEl) {
        noteEl.textContent = data.note;
        noteEl.className   = 'stat-note ' + data.noteClass;
    }
}

function updateButton(isBefore) {
    var btn = document.getElementById('sysBtn');
    if (isBefore) {
        btn.className = 'sys-btn sys-btn-locked';
        btn.disabled  = true;
    } else {
        btn.className = 'sys-btn sys-btn-active';
        btn.disabled  = false;
    }
}
```

---

## 3. Timeline

**When:** Change eliminates a delay or timing issue in a process.

### HTML Skeleton

```html
<div class="hero-visual">
    <div class="timeline-wrap">

        <!-- T=0 event -->
        <div class="tl-event tl-event-start">
            <div class="tl-event-dot tl-dot-blue"></div>
            <div class="tl-event-body">
                <div class="tl-label">T = 0</div>
                <div class="tl-title">[Initial action] ✏️</div>
                <div class="tl-sub">[Description of what happened]</div>
            </div>
        </div>

        <div class="tl-line"></div>

        <!-- Cache/delay block — only visible in "before" state -->
        <div class="tl-cache-block" id="tlCacheBlock">
            <div class="tl-cache-inner">
                <div class="tl-cache-icon">💾</div>
                <div class="tl-cache-text">
                    <strong>[Delay reason]</strong>
                    <span id="tlCacheTime">[duration description]</span>
                </div>
            </div>
        </div>

        <div class="tl-line tl-line-dashed" id="tlDashedLine"></div>

        <!-- Delivery event -->
        <div class="tl-event" id="tlDeliveryEvent">
            <div class="tl-event-dot" id="tlDeliveryDot"></div>
            <div class="tl-event-body">
                <div class="tl-label" id="tlDeliveryLabel">T = ?</div>
                <div class="tl-title" id="tlDeliveryTitle">[Delivery description]</div>
                <div class="tl-sub" id="tlDeliverySub">[Uncertainty description]</div>
            </div>
        </div>

        <div class="tl-line tl-line-short" id="tlLineShort"></div>

        <!-- End user event -->
        <div class="tl-event tl-event-end" id="tlEndEvent">
            <div class="tl-event-dot" id="tlEndDot"></div>
            <div class="tl-event-body">
                <div class="tl-label" id="tlEndLabel">[End user label]</div>
                <div class="tl-title" id="tlEndTitle">⚠️ [Bad outcome]</div>
                <div class="tl-sub" id="tlEndSub">[Explanation]</div>
            </div>
        </div>

        <!-- State strip -->
        <div class="tl-state-strip" id="tlStateStrip">
            <span id="tlStateText">⚠ [Warning text]</span>
        </div>

    </div>
</div>
```

### CSS Specific to Timeline

```css
.timeline-wrap {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0;
    width: 100%;
    max-width: 360px;
}

.tl-event {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    width: 100%;
}

.tl-event-dot {
    width: 14px;
    height: 14px;
    border-radius: 50%;
    flex-shrink: 0;
    margin-top: 4px;
    transition: all 0.5s ease;
    position: relative;
    z-index: 1;
}

.tl-dot-blue   { background: var(--blue);  box-shadow: 0 0 8px var(--blue-glow);  }
.tl-dot-red    { background: var(--red);   box-shadow: 0 0 8px var(--red-glow);   animation: blink 1.5s ease-in-out infinite; }
.tl-dot-green  { background: var(--green); box-shadow: 0 0 8px var(--green-glow); }
.tl-dot-amber  { background: var(--amber); box-shadow: 0 0 8px var(--amber-glow); }

.tl-line {
    width: 2px;
    height: 28px;
    background: var(--border-light);
    margin-left: 6px;
    transition: all 0.5s ease;
}

.tl-line-dashed {
    border-left: 2px dashed var(--border-light);
    background: transparent;
    height: 20px;
    margin-left: 6px;
}

.tl-cache-block {
    margin-left: 28px;
    margin-bottom: 4px;
    transition: all 0.5s ease;
    max-height: 60px;
    overflow: hidden;
    opacity: 1;
}

.tl-cache-block.collapsed {
    max-height: 0;
    opacity: 0;
    margin-bottom: 0;
}

.tl-cache-inner {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.55rem 0.9rem;
    background: var(--amber-muted);
    border: 1px solid rgba(251, 191, 36, 0.25);
    border-radius: var(--radius-md);
}

.tl-state-strip {
    margin-top: 1rem;
    padding: 0.55rem 0.9rem;
    border-radius: var(--radius-md);
    font-size: 0.72rem;
    font-weight: 600;
    background: var(--red-muted);
    border: 1px solid rgba(248, 113, 113, 0.2);
    color: var(--red);
    transition: all 0.5s ease;
    width: 100%;
}

.tl-state-strip.strip-good {
    background: var(--green-muted);
    border-color: rgba(52, 211, 153, 0.25);
    color: var(--green);
}
```

### JS Toggle Pattern

```javascript
function updateTimeline(isBefore) {
    var cacheBlock = document.getElementById('tlCacheBlock');
    var stateStrip = document.getElementById('tlStateStrip');

    if (isBefore) {
        cacheBlock.classList.remove('collapsed');
        stateStrip.classList.remove('strip-good');
        // Update dots, labels, titles to show broken/delayed state
    } else {
        cacheBlock.classList.add('collapsed');
        stateStrip.classList.add('strip-good');
        // Update dots, labels, titles to show instant/fixed state
    }
}
```
