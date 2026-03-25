---
name: brainstorm
description: >
  Hypothesis generation — broad exploration to diverge research ideas and verify logical gaps.
  가설 수립, 브레인스토밍, 아이디어 탐색.
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /brainstorm — Hypothesis Generation

## Role

- **Lead**: Gemini (broad context for cross-referencing papers, connecting ideas)
- **Support (Claude)**: Logically verify Lead's draft and write review

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode
3. `.research/wisdom.md` — Past failure/success patterns

**Scope Mode restriction**: In `REFINEMENT` or `FOCUSED` mode, avoid exploring new directions.

## Claude's Behavior (Support)

### Phase 1: Review Draft
1. Read `.research/plans/hypothesis-{topic}-draft.md`.
2. Verify each hypothesis:
   - **Logical consistency**: Is the premise → conclusion flow free of logical leaps?
   - **Feasibility**: Can this be tested in our environment (simulators, hardware)?
   - **Novelty**: Are we re-solving an already-solved problem?
   - **Wisdom check**: Does this conflict with past lessons in wisdom.md?

### Phase 2: Write Review
3. Write `.research/plans/hypothesis-{topic}-review.md`.
4. Structured feedback per hypothesis:
   - **Strengths**: Logically sound aspects
   - **Weaknesses/Concerns**: Identified logical gaps
   - **Suggestions**: Directions for improvement or alternatives
   - **Priority recommendation**: Relative promise ranking among hypotheses

## Hard Gate

Code writing, file editing, and command execution are **blocked** in this skill.
Focus exclusively on thinking and analysis.

## Slop Check

Do not propose experiments or frameworks. Ideas only. See AGENTS.md Section 10.

## Evidence Required

Each idea in the review must cite at least one related paper, prior result, or specific observation as supporting rationale.

## Must NOT

- Generate code
- Finalize parameters
- Claim ideas are "validated" without evidence
- Dismiss ideas without stated reasoning

## Output

| Role | Output File |
|------|------------|
| Lead (Gemini) | `.research/plans/hypothesis-{topic}-draft.md` |
| Support (Claude) | `.research/plans/hypothesis-{topic}-review.md` |
| Final (Lead incorporates) | `.research/plans/hypothesis-{topic}-final.md` |
