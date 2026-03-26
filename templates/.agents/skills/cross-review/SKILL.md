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
- Antigravity initiates → Claude reviews (via `invoke-claude.sh`, fully automatic)
- Claude Code initiates → Antigravity reviews (via signal + `/pickup`)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode
3. An artifact that needs cross-agent review (e.g., `*-draft.md`)

## Antigravity's Behavior (Initiator — Antigravity → Claude)

### Phase 1: Identify Artifact
1. Determine which artifact needs cross-review from conversation context.
2. If ambiguous, ask the user which artifact to send.
3. Determine the skill context from the artifact path pattern:
   - `.research/plans/hypothesis-*` → brainstorm
   - `.research/plans/experiment-*` → experiment-design
   - `.research/feedback/analysis-*` → analyze
   - `.research/feedback/validation-*` → validate
   - `docs/sections/*` → document
4. Determine the output path: replace `-draft.md` with `-review.md` (or construct appropriate review path).

### Phase 2: Invoke Claude Directly
5. Run `invoke-claude.sh` to call Claude Code:
   ```
   bash scripts/invoke-claude.sh \
     --skill {detected_skill} \
     --action review \
     --artifact "{artifact_path}" \
     --output "{review_path}"
   ```
   The script automatically selects the right Claude model from the skill's `claude-model` field.

6. Wait for Claude to complete. Claude will write the review file.

### Phase 3: Read and Incorporate
7. Read the review file Claude produced (`*-review.md`).
8. Incorporate feedback:
   - Address all items under **MUST FIX**
   - Consider items under **SUGGESTIONS** (apply if appropriate)
   - Preserve sections marked as **VERIFIED**
9. Write the final artifact (`*-final.md`).

### Phase 4: Report
10. Report to the user:
    - Summary of Claude's review findings
    - What was incorporated vs what was preserved
    - Path to the final artifact

**This entire cycle completes automatically without user intervention.**

## Antigravity's Behavior (Responder — Claude → Antigravity)

When invoked via `/pickup` to process a Claude-initiated signal:
1. Read the signal from `.research/handoff/queue/`.
2. Read the artifact specified in the signal.
3. Follow the skill's Support/Lead behavior as appropriate.
4. Write the review/result to the appropriate path.
5. Optionally call `invoke-claude.sh` for follow-up steps (e.g., incorporation).
6. Move signal to `.research/handoff/done/`.

## Scope Mode Awareness

- In `FOCUSED` mode: Cross-review is allowed for implementation verification.
- In `WRITING` mode: Cross-review is allowed for document review.
- Do not initiate cross-review that conflicts with the current Scope Mode.

## Hard Gate

All tools are available — this skill needs Bash to run `invoke-claude.sh`.

## Slop Check

Do not over-engineer the handoff. Invoke Claude and let it do its work.
See AGENTS.md Section 10.

## Must NOT

- Skip the `invoke-claude.sh` call when Antigravity is the initiator (direct CLI call is the mechanism)
- Modify Claude's review files after reading them
- Auto-process `requires_human: true` signals without researcher confirmation
- Bundle multiple artifacts into a single cross-review (one artifact per call)

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Action | Output |
|--------|--------|
| Claude's review | `*-review.md` (written by Claude via `invoke-claude.sh`) |
| Final artifact | `*-final.md` (after incorporating review) |
| Signal (if responder) | Signal moved to `.research/handoff/done/` |
