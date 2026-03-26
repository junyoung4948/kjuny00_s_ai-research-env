---
name: analyze
description: >
  Result analysis — identify patterns, trends, and anomalies in experiment results, recommend visualizations.
  결과 분석, 패턴 파악, 트렌드, 이상치 분석.
claude-model: sonnet
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /analyze — Result Analysis

## Role

- **Lead**: Gemini (large context for pattern detection in bulk data, multimodal)
- **Support (Claude)**: Verify numerical accuracy of Lead's analysis

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode
3. `.research/plans/experiment-{name}-final.md` — Experiment design
4. `.research/feedback/validation-{name}.md` — Validation report (if available)
5. `.research/wisdom.md` — Past analysis patterns

**Scope Mode restriction**: In `WRITING` mode, do not start new analysis — organize existing results instead.

## Claude's Behavior (Support)

### Phase 1: Review Gemini's Analysis
1. Read `.research/feedback/analysis-{name}-draft.md`.
2. Verify:
   - **Numerical accuracy**: Do Gemini's cited numbers match the raw data?
   - **Statistical claims**: Are calculations behind claims correct?
   - **Fair comparison**: Are different conditions compared fairly?
   - **Missing perspectives**: Are there important patterns or anomalies Gemini missed?

### Phase 2: Write Review
3. Write `.research/feedback/analysis-{name}-review.md`.
4. Structured feedback:
   - **Confirmed findings**: Numerically accurate analysis results
   - **Corrections needed**: Erroneous numbers or claims
   - **Additional analysis suggestions**: Missed patterns or extra visualizations
   - **Visualization feedback**: Comments on recommended visualization methods

## Hard Gate

Code writing, file editing, and command execution are **blocked** in this skill.
Focus exclusively on analysis review and feedback.

## FROZEN Directory Warning

`profiling/results/` and `simulation/results/` are read-only.
Read originals directly for analysis.

## Slop Check

Scale analysis complexity to data volume. Do not over-interpret sparse data.

## Evidence Required

Every claim must cite specific numbers: "X increased Y%, from A to B" format.

## Must NOT

- Apply statistics disproportionate to data scale
- Jump from correlation to causation
- Omit inconvenient data points

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Role | Output File |
|------|------------|
| Lead (Gemini) | `.research/feedback/analysis-{name}-draft.md` |
| Support (Claude) | `.research/feedback/analysis-{name}-review.md` |
| Final (Lead incorporates) | `.research/feedback/analysis-{name}-final.md` |

## Auto-Handoff (Optional)

After Lead (Gemini) completes the draft, it can automatically request Claude to review:
- **Antigravity Lead**: `bash scripts/invoke-claude.sh --skill analyze --action review --artifact ".research/feedback/analysis-{name}-draft.md" --output ".research/feedback/analysis-{name}-review.md"`
- Once review is complete, read it directly and incorporate into `*-final.md` — no researcher intervention needed.
