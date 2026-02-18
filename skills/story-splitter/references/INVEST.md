# INVEST Principle Reference

## The Six Dimensions

| Dimension | Definition | Pass Criteria | Fail Example |
|:----------|:-----------|:--------------|:-------------|
| **Independent** | Can be developed, tested, and deployed without depending on incomplete stories | No blocked-by relationships to in-progress work | "Frontend story" that cannot start until "Backend story" is done |
| **Negotiable** | Implementation details are flexible; scope can be discussed without breaking the deliverable | Acceptance criteria define *what*, not *how* | Story that prescribes exact SQL queries or class names |
| **Valuable** | Delivers measurable value to a user, customer, or stakeholder | A stakeholder can verify the outcome | "Set up database tables" — no user-visible value |
| **Estimable** | Team can estimate effort with reasonable confidence | Requirements are clear enough to break into tasks | "Integrate with external system" — no API docs, no contract |
| **Small** | Fits within a single sprint (typically 1-8 SP) | Can be completed in ≤ 5 working days | 13+ SP story spanning multiple architectural layers |
| **Testable** | Has clear, verifiable acceptance criteria | At least one Given/When/Then or checklist criterion | "Improve performance" — no target metric defined |

---

## Vertical vs. Horizontal Slicing

### Vertical Slicing (Correct)

Each story cuts through **all layers** to deliver end-to-end functionality:

```
┌─────────────────────────────────────┐
│           Story 1 (Vertical)        │
│  ┌─────┐  ┌─────┐  ┌─────┐          │
│  │ UI  │→ │ API │→ │ DB  │          │
│  └─────┘  └─────┘  └─────┘          │
│  Analysis → Development → Testing   │
└─────────────────────────────────────┘
```

**Example:** "As a user, I can view my claim error details via the new endpoint"
- Analysis: endpoint design, DTO design
- Development: controller + service + repository + response mapping
- Testing: unit tests + integration test + manual verification

### Horizontal Slicing (Forbidden)

Stories are split by technical layer — each story is incomplete alone:

```
┌───────────────────────┐
│  Story A: Backend     │  ← Not Valuable alone
├───────────────────────┤
│  Story B: Frontend    │  ← Not Independent (blocked by A)
├───────────────────────┤
│  Story C: Testing     │  ← Not Independent (blocked by A+B)
└───────────────────────┘
```

**Why it fails:**
- Story A (Backend) is not **Valuable** — no user can verify it
- Story B (Frontend) is not **Independent** — blocked until A is done
- Story C (Testing) is not **Valuable** or **Independent**

---

## Common Anti-Patterns

| Anti-pattern | Violated Dimensions | Correct Approach |
|:-------------|:--------------------|:-----------------|
| "Write tests for feature X" | Independent, Valuable | Tests are part of each story's DoD, not separate tickets |
| "Research / Spike" without timebox | Estimable, Small | Timebox to 1-2 days with clear output artifact |
| "Refactor module Y" without measurable goal | Valuable, Testable | Define measurable outcome (e.g., reduce latency by 30%) |
| "Setup infrastructure" | Valuable | Combine with the first feature that uses the infrastructure |
| Story > 8 SP | Small | Decompose further using vertical slicing |

---

## MVP Scoping Guidelines

### What belongs in MVP

- Features that solve the **core problem** stated in the requirement
- The **minimum set** of stories that delivers a working, demonstrable product increment
- Stories that **unblock** other teams or downstream work

### What does NOT belong in MVP

- "Nice to have" enhancements (→ Post-MVP)
- Legacy cleanup or refactoring (→ Tech Debt)
- Performance optimization beyond baseline requirements (→ Post-MVP)
- UI polish beyond functional correctness (→ Post-MVP)

### Tiering framework

| Tier | Criteria | Sprint Placement |
|:-----|:---------|:-----------------|
| **MVP (Must Have)** | Without this, the product increment has no value | Sprint N |
| **Post-MVP (Should Have)** | Enhances value but core works without it | Sprint N+1 |
| **Tech Debt (Nice to Have)** | Cleanup, optimization, deprecated code removal | Sprint N+2 or later |

---

## Lifecycle Integrity Check

Every story **must** include all three phases in its scope:

| Phase | Minimum Content |
|:------|:----------------|
| **Analysis** | Requirements clarification, design decisions, dependency check |
| **Development** | Code changes across all necessary layers (end-to-end) |
| **Testing** | Unit tests, acceptance criteria verification, edge case coverage |

> A story without testing is not Done.
> A story without analysis is a guess.
> A story without development is a wish.
