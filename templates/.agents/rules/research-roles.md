# Research Roles — Antigravity Rules

This file is auto-loaded by Antigravity from `.agents/rules/`.

---

## Lead/Support Behavior

### When You Are Lead
- Create `*-draft.md` files as the primary artifact.
- You own the deliverable for that phase.
- Incorporate feedback from the Support model's `*-review.md` to produce `*-final.md`.

### When You Are Support
- Review the Lead's `*-draft.md`.
- Write your feedback in a `*-review.md` file.
- **Never modify the original draft.** Write feedback in a separate review file only.

---

## Gemini Lead Phases

| Phase | Output Path | Key Behavior |
|-------|------------|-------------|
| Hypothesis generation | `.research/plans/hypothesis-{topic}-draft.md` | Generate at least 3 ideas. No code writing. |
| Analysis script implementation | Relevant script path | Editor inline, verify visualization output |
| Result analysis | `.research/feedback/analysis-{name}-draft.md` | Identify patterns/trends, recommend visualizations |
| Paper drafting | `docs/sections/{section}-draft.md` | Build narrative structure. Never delete existing content. |

## Gemini Support Phases

| Phase | Output Path | Key Behavior |
|-------|------------|-------------|
| Experiment design | `.research/plans/experiment-{name}-review.md` | Provide exploratory suggestions to complement Claude's design |
| Result validation | (N/A) | Claude is sole Lead |
