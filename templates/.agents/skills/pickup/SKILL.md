---
name: pickup
description: >
  Process pending handoff tasks from the other agent. Check and handle queued cross-review requests.
  대기 중인 상대 에이전트의 handoff 요청을 처리.
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

# /pickup — Process Pending Handoffs

## Role

Process pending handoff signals from `.research/handoff/queue/` that are addressed to Antigravity.

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode

## Behavior

### Phase 1: Scan Queue
1. List all `*.json` files in `.research/handoff/queue/`.
2. Read each file and filter for signals where `"to": "antigravity"` and `"status": "pending"`.
3. If no pending signals found, report: "No pending handoffs for Antigravity."
4. If multiple signals found, list them and process in chronological order (oldest first).

### Phase 2: Process Each Signal
For each pending signal:

5. Update signal status to `"processing"`.
6. Check `requires_human`:
   - If `true`: Report to user and ask for confirmation before processing.
   - If `false`: Proceed automatically.
7. Read the artifact specified in the signal's `artifact` field.
8. Determine behavior from the signal's `skill` and `action` fields:

   | action | behavior |
   |--------|----------|
   | `review` | Follow the skill's Support/Lead review phases. Write `*-review.md`. |
   | `validate` | Provide validation support per skill context. |
   | `incorporate` | Read review file, incorporate feedback into `*-final.md`. |
   | `analyze` | Follow `/analyze` Lead behavior. Write `analysis-*-draft.md`. |
   | `custom` | Follow the instructions in the signal's `context` field. |

9. Write the output artifact.

### Phase 3: Invoke Claude for Follow-Up (Optional)
10. If the completed action naturally chains to a Claude step (e.g., after writing a review, Claude should incorporate):
    ```
    bash scripts/invoke-claude.sh \
      --skill {skill} --action incorporate \
      --artifact "{review_path}" \
      --output "{final_path}"
    ```
    This allows the full cycle to complete within one Antigravity turn.

### Phase 4: Complete Signal
11. Add `result_artifact` and `completed_at` fields to the signal.
12. Move the signal file from `queue/` to `done/`.

### Phase 5: Report
13. Summarize what was processed:
    - Number of signals processed
    - For each: skill, action, artifact, result
    - Any Claude follow-up invocations and their results
    - Final artifact paths

## Safety Rules

- **3-Strike Rule applies**: If processing fails 3 times, escalate to researcher.
- **FROZEN directories**: Never write to `profiling/results/` or `simulation/results/`.
- **requires_human**: Always respect this flag. Never auto-process Taste decisions.

## Must NOT

- Delete signal files (move to `done/`, never delete)
- Process signals addressed to `"claude"` (only process `"to": "antigravity"`)
- Modify the original artifact when acting as reviewer (write in separate files)
- Skip the signal status update workflow (pending → processing → done)

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Action | Output |
|--------|--------|
| Review | `*-review.md` in appropriate directory |
| Incorporate | `*-final.md` (possibly via `invoke-claude.sh` follow-up) |
| Signal | Moved to `.research/handoff/done/` |
