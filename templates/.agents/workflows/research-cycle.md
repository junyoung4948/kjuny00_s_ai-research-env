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

```
[Gemini] /brainstorm → hypothesis-draft.md
    ↓ (researcher asks Claude to review)
[Claude] review → hypothesis-review.md
    ↓ (researcher asks Gemini to incorporate feedback)
[Gemini] incorporate → hypothesis-final.md
    ↓ (researcher selects hypothesis)
```

**Allowed**: Free idea exploration, literature survey
**Avoid**: Code writing, parameter decisions

---

### Phase 2: REFINEMENT (Specification)

**Goal**: Design experiments for the selected hypothesis.

```
[Claude] /experiment-design → experiment-draft.md
    ↓ (researcher asks Gemini to review)
[Gemini] review → experiment-review.md
    ↓ (researcher asks Claude to incorporate feedback)
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
[Gemini] /analyze → analysis-draft.md
    ↓
[Claude] review → analysis-review.md
    ↓
[Gemini] incorporate → analysis-final.md
```

**Allowed**: Code implementation, experiment execution, debugging
**Avoid**: Direction changes, new ideas

---

### Phase 4: WRITING (Documentation)

**Goal**: Organize research results into papers/reports.

```
[Gemini] /document → {section}-draft.md
    ↓
[Claude] review → {section}-review.md
    ↓
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

## Handoff Checklist

Items for the researcher to verify when passing artifacts between models:

- [ ] Lead completed `*-draft.md`?
- [ ] Requested review from Support?
- [ ] Support completed `*-review.md`?
- [ ] Requested Lead to incorporate review?
- [ ] Lead produced `*-final.md`?
- [ ] Researcher verified the final artifact?
