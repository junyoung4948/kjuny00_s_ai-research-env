---
name: document
description: >
  Paper/report writing — systematically document research results. Gemini drafts, Claude reviews.
  논문 작성, 보고서 문서화, 기술 교정.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - AskUserQuestion
---

# /document — Paper/Report Writing

## Role

- **Lead (Draft)**: Gemini (narrative construction, initial draft)
- **Support (Review)**: Claude (technical accuracy verification)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode (`WRITING` recommended)
3. `.research/plans/hypothesis-{topic}-final.md` — Finalized hypothesis
4. `.research/plans/experiment-{name}-final.md` — Experiment design
5. `.research/feedback/analysis-{name}-final.md` — Analysis results
6. `.research/feedback/validation-{name}.md` — Validation results

## Claude's Behavior (Support — Review)

### Phase 1: Review Draft
1. Read `docs/sections/{section}-draft.md`.
2. Verify:

**Technical accuracy**
- Do cited numbers match experiment results?
- Does methodology description match actual experiment design?
- Are formulas/algorithms correct?

**Logical flow**
- Are claims and evidence clearly connected?
- Is the flow between sections natural?

**Completeness**
- Are any experimental conditions or results missing?
- Are limitations adequately mentioned?

### Phase 2: Write Review
3. Write `docs/sections/{section}-review.md`.
4. Structured feedback:
   - **Must Fix**: Technical errors, numerical inconsistencies
   - **Suggestions**: Expression, structure, explanation improvements
   - **Verified**: Sections confirmed as accurate

### Hard Gate Exception

**Do not directly modify the original draft.**
Write feedback in a separate review file only.
Use Edit/Write tools only for creating the review file.

## Slop Check

Scale output length to finding significance. No padding.

## Evidence Required

Every technical claim must reference the source artifact file path and specific numbers.

## Must NOT

- Directly modify the draft (Support role only)
- Make claims without experimental evidence
- Delete limitations sections

## Output

| Role | Output File |
|------|------------|
| Lead (Gemini) | `docs/sections/{section}-draft.md` |
| Support (Claude) | `docs/sections/{section}-review.md` |
| Final (Lead incorporates) | `docs/sections/{section}-final.md` |
