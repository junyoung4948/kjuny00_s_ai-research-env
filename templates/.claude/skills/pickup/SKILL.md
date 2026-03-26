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

Process pending handoff signals from `.research/handoff/queue/` that are addressed to this agent.

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/scope-mode.txt` — Check current mode

## Behavior

### Phase 1: Scan Queue
1. List all `*.json` files in `.research/handoff/queue/`.
2. Read each file and filter for signals where `"to": "claude"` and `"status": "pending"`.
3. If no pending signals found, report: "No pending handoffs for Claude."
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
   | `review` | Follow the skill's Support review phases. Write `*-review.md`. |
   | `validate` | Follow `/validate` behavior. Write `validation-*.md`. |
   | `incorporate` | Read the review file, incorporate into `*-final.md`. |
   | `analyze` | Follow `/analyze` Support behavior. Write `analysis-*-review.md`. |
   | `custom` | Follow the instructions in the signal's `context` field. |

9. Write the output artifact.

### Phase 3: Complete Signal
10. Add `result_artifact` and `completed_at` fields to the signal.
11. Move the signal file from `queue/` to `done/`.
12. If the completed work requires a follow-up by Antigravity (e.g., incorporation after review),
    create a new signal using `create-handoff.sh`:
    ```
    bash scripts/create-handoff.sh \
      --from claude --to antigravity \
      --action incorporate --skill {skill} \
      --artifact "{review_path}"
    ```

### Phase 4: Report
13. Summarize what was processed:
    - Number of signals processed
    - For each: skill, action, artifact, result
    - Any follow-up signals created

## Safety Rules

- **3-Strike Rule applies**: If processing fails 3 times, escalate to researcher.
- **FROZEN directories**: Never write to `profiling/results/` or `simulation/results/`.
- **requires_human**: Always respect this flag. Never auto-process Taste decisions.

## Must NOT

- Delete signal files (move to `done/`, never delete)
- Process signals addressed to `"antigravity"` (only process `"to": "claude"`)
- Modify the original artifact (write review/feedback in separate files)
- Skip the signal status update workflow (pending → processing → done)

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Action | Output |
|--------|--------|
| Review | `*-review.md` in appropriate directory |
| Validate | `.research/feedback/validation-*.md` |
| Incorporate | `*-final.md` |
| Signal | Moved to `.research/handoff/done/` |
