---
name: experiment-design
description: >
  Experiment design — systematic specification of variable control, parameter spaces, and methodology.
  실험 설계, 파라미터 정의, 변수 통제.
claude-model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /experiment-design — Experiment Design

## Role

- **Lead**: Claude (precise reasoning for variable control, parameter space definition)
- **Support**: Gemini (exploratory suggestions)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode
3. `.research/plans/hypothesis-{topic}-final.md` — Finalized hypothesis
4. `.research/wisdom.md` — Past experiment lessons

**Scope Mode restriction**: In `EXPLORATION` mode, discuss direction only — do not finalize parameters.

## Claude's Behavior (Lead)

### Phase 1: Atomic Decision with Researcher
Confirm **one item at a time** with the researcher:

1. **Dependent Variable**: What will we measure?
2. **Independent Variable**: What will we vary?
3. **Control Variable**: What will we hold constant?
4. **Tool/Simulator**: Which tool will we use?
5. **Parameter Ranges**: Exploration range for each variable?
6. **Baseline**: What is the comparison reference?
7. **Success Criteria**: What result supports/refutes the hypothesis?

> Do not bundle multiple decisions into a single proposal (Atomic Decision principle).

### Phase 2: Write Experiment Plan
Once all decisions are confirmed, write in this structure:

```markdown
# Experiment Plan: {name}

## Hypothesis
(Quoted from hypothesis-final)

## Experimental Variables
| Type | Variable | Values/Range |
|------|----------|-------------|
| Independent | ... | ... |
| Dependent | ... | ... |
| Control | ... | ... |

## Tools and Environment
- Simulator: ...
- Workload: ...
- Hardware/Environment: ...

## Experiment Matrix
(Full parameter combinations)

## Baseline
...

## Success Criteria
...

## Effort Estimate
| Tag | Meaning |
|-----|---------|
| Quick | <1 hour (config change, rerun existing script) |
| Short | 1-4 hours (small script, few parameter sweeps) |
| Medium | 1-2 days (new simulation setup, mid-scale DSE) |
| Large | 3+ days (new simulator model, large sweep, new tool integration) |

Estimated effort for this experiment: {Tag} — {rationale}

## Must NOT (for this experiment)
- (List experiment-specific prohibitions)
```

### Phase 3: Update decisions.md
Record key design decisions in `.research/decisions.md`.

## Hard Gate

Code writing, file editing, and command execution are **blocked** in this skill.
Focus exclusively on design and planning.

## Slop Check

Do not build automation frameworks. Define the simplest experiment that tests the hypothesis.

## Evidence Required

The output must include a researcher-confirmed parameter table. Unconfirmed = incomplete.

## Must NOT

- Bundle multiple decisions into one proposal
- Set parameters without researcher confirmation
- Omit baseline definition
- Assume tool availability without verification

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Role | Output File |
|------|------------|
| Lead (Claude) | `.research/plans/experiment-{name}-draft.md` |
| Support (Gemini) | `.research/plans/experiment-{name}-review.md` |
| Final (Lead incorporates) | `.research/plans/experiment-{name}-final.md` |

## Auto-Handoff (Optional)

After Lead (Claude) completes the draft, it can create a signal to request Gemini to review:
- **Claude Lead**: `bash scripts/create-handoff.sh --from claude --to antigravity --action review --skill experiment-design --artifact ".research/plans/experiment-{name}-draft.md"`
- User runs `/pickup` in Antigravity → Gemini reviews → calls `invoke-claude.sh` to have Claude incorporate feedback.
