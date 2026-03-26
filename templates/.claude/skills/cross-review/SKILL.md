---
name: cross-review
description: >
  Cross-agent review cycle — send artifact to the other agent for validation, process feedback, and incorporate.
  교차 검증 — 상대 에이전트에게 검증 요청, 피드백 처리 및 반영.
claude-model: sonnet
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# /cross-review — Cross-Agent Review Cycle

## Role

- **Initiator**: The agent that has an artifact to be reviewed by the other agent
- Claude Code initiates → Antigravity reviews (via signal + `/pickup`)
- Antigravity initiates → Claude reviews (via `invoke-claude.sh`)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode
3. An artifact that needs cross-agent review (e.g., `*-draft.md`)

## Claude's Behavior (Initiator — Claude → Antigravity)

### Phase 1: Identify Artifact
1. Determine which artifact needs cross-review from conversation context.
2. If ambiguous, ask the user which artifact to send.
3. Determine the skill context from the artifact path pattern:
   - `.research/plans/hypothesis-*` → brainstorm
   - `.research/plans/experiment-*` → experiment-design
   - `.research/feedback/analysis-*` → analyze
   - `.research/feedback/validation-*` → validate
   - `docs/sections/*` → document

### Phase 2: Create Handoff Signal
4. Run `bash scripts/create-handoff.sh` with appropriate arguments:
   ```
   bash scripts/create-handoff.sh \
     --from claude --to antigravity \
     --action review --skill {detected_skill} \
     --artifact "{artifact_path}" \
     --context "{description of what to review}"
   ```
5. For "Taste" decisions (AGENTS.md §8), add `--requires-human`.

### Phase 3: Notify User
6. Report to the user:
   - What artifact was sent for review
   - What skill context applies
   - Instruction: "Antigravity에서 `/pickup` 실행하면 자동으로 처리됩니다."

### Phase 4: Incorporate (when user returns with results)
7. If the user returns after Antigravity's `/pickup` completed the review:
   - Read the `*-review.md` file
   - Incorporate feedback into `*-final.md`
   - Report what was changed and what was already verified

## Claude's Behavior (Responder — Antigravity → Claude)

When Claude is invoked by `invoke-claude.sh` (non-interactive mode):
1. Read the artifact specified in the prompt.
2. Follow the skill's Support behavior phases (from the skill's SKILL.md).
3. Write the review to the specified output path.
4. Apply all safety rules.

## Scope Mode Awareness

- In `FOCUSED` mode: Cross-review is allowed for implementation verification.
- In `WRITING` mode: Cross-review is allowed for document review.
- Do not initiate cross-review that conflicts with the current Scope Mode.

## Hard Gate

All tools are available — this skill needs Bash to run `create-handoff.sh`.

## Slop Check

Do not over-engineer the handoff. Create the signal and let the other agent do its work.
See AGENTS.md Section 10.

## Must NOT

- Skip the signal file creation (needed for audit trail)
- Modify the other agent's review files
- Auto-process `requires_human: true` signals without researcher confirmation
- Bundle multiple artifacts into a single cross-review (one artifact per signal)

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Action | Output |
|--------|--------|
| Signal creation | `.research/handoff/queue/{timestamp}-claude-to-antigravity-{action}.json` |
| After incorporation | `*-final.md` (incorporating review feedback) |
