# Research Cycle Workflow

This file is referenced by Antigravity from `.agents/workflows/`.

---

## Full Research Cycle

```
EXPLORATION → REFINEMENT → FOCUSED → WRITING
     ↑                                  |
     └──────── (reflect & re-explore) ──┘
```

### Phase 1: EXPLORATION (Direction Search)

**Goal**: Generate and diverge research ideas, form hypotheses.

#### Manual Handoff
```
[Gemini] /brainstorm → hypothesis-draft.md
    ↓ (researcher asks Claude to review)
[Claude] review → hypothesis-review.md
    ↓ (researcher asks Gemini to incorporate feedback)
[Gemini] incorporate → hypothesis-final.md
    ↓ (researcher selects hypothesis)
```

#### Auto-Handoff (starting from Antigravity)
```
[Gemini] /brainstorm → hypothesis-draft.md
    ↓ invoke-claude.sh (automatic)
[Claude] review → hypothesis-review.md
    ↓ (Gemini reads directly)
[Gemini] incorporate → hypothesis-final.md
    ↓ (researcher selects hypothesis)
```

**Allowed**: Free idea exploration, literature survey
**Avoid**: Code writing, parameter decisions

---

### Phase 2: REFINEMENT (Specification)

**Goal**: Design experiments for the selected hypothesis.

#### Manual Handoff
```
[Claude] /experiment-design → experiment-draft.md
    ↓ (researcher asks Gemini to review)
[Gemini] review → experiment-review.md
    ↓ (researcher asks Claude to incorporate feedback)
[Claude] incorporate → experiment-final.md
```

#### Auto-Handoff (starting from Claude)
```
[Claude] /experiment-design → experiment-draft.md
    ↓ signal creation → user runs /pickup
[Gemini] /pickup → review → experiment-review.md
    ↓ invoke-claude.sh (automatic)
[Claude] incorporate → experiment-final.md
```

**Allowed**: Experiment design, variable definition
**Avoid**: Proposing new research directions

---

### Phase 3: FOCUSED (Execution)

**Goal**: Implement, run, and validate experiments.

```
[Claude] Simulation script implementation
[Gemini] Analysis script implementation
    ↓
[Claude] Experiment execution/monitoring
    ↓
[Claude] /validate → validation-{name}.md
    ↓ (on failure)
[Claude] /diagnose → diagnosis-{name}.md (3-Strike Rule)
    ↓ (on success)
```

#### Analysis — Manual Handoff
```
[Gemini] /analyze → analysis-draft.md
    ↓
[Claude] review → analysis-review.md
    ↓
[Gemini] incorporate → analysis-final.md
```

#### Analysis — Auto-Handoff (starting from Antigravity)
```
[Gemini] /analyze → analysis-draft.md
    ↓ invoke-claude.sh (automatic)
[Claude] review → analysis-review.md
    ↓ (Gemini reads directly)
[Gemini] incorporate → analysis-final.md
```

**Allowed**: Code implementation, experiment execution, debugging
**Avoid**: Direction changes, new ideas

---

### Phase 4: WRITING (Documentation)

**Goal**: Organize research results into papers/reports.

#### Manual Handoff
```
[Gemini] /document → {section}-draft.md
    ↓
[Claude] review → {section}-review.md
    ↓
[Gemini] incorporate → {section}-final.md
```

#### Auto-Handoff (starting from Antigravity)
```
[Gemini] /document → {section}-draft.md
    ↓ invoke-claude.sh (automatic)
[Claude] review → {section}-review.md
    ↓ (Gemini reads directly)
[Gemini] incorporate → {section}-final.md
```

**Allowed**: Paper writing, visualization
**Avoid**: New experiments, large code changes

---

### After Cycle Completion: Reflect

```
[Claude] /reflect → retros/{date}.md
    → update wisdom.md
    → update context.md
    → (discuss next direction with researcher)
```

---

## 5-Step Auto-Orchestration Pipeline

When starting the full cycle from Antigravity, the entire pipeline can complete without researcher intervention:

```
Step 1: [Gemini] Web research → write source material
Step 2: invoke-claude.sh → [Claude/Opus] write plan                ← automatic
Step 3: [Gemini] Validate plan + draft implementation              ← automatic (already in Antigravity)
Step 4: invoke-claude.sh → [Claude/Sonnet] verify draft            ← automatic
Step 5: [Gemini] Write result summary for researcher               ← automatic
```

When starting from Claude Code: signal + `/pickup` once, then the rest is automatic.

---

## Handoff Checklist

### Manual Handoff
- [ ] Lead completed `*-draft.md`?
- [ ] Requested review from Support?
- [ ] Support completed `*-review.md`?
- [ ] Requested Lead to incorporate review?
- [ ] Lead produced `*-final.md`?
- [ ] Researcher verified the final artifact?

### Auto-Handoff
- [ ] Lead completed `*-draft.md`?
- [ ] `invoke-claude.sh` or signal created for review?
- [ ] Support review completed (`*-review.md`)?
- [ ] Feedback incorporated into `*-final.md`?
- [ ] Researcher verified the final artifact?
