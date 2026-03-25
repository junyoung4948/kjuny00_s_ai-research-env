---
name: reflect
description: >
  Retrospective — review the research cycle, organize insights, and update context/wisdom.
  회고, 인사이트 정리, 교훈 기록.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - AskUserQuestion
---

# /reflect — Retrospective

## Role

- **Lead**: Claude (Memory system for cross-session continuity)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/wisdom.md` — Existing insights
3. `.research/decisions.md` — Existing decision records
4. Recent work artifacts (plans, feedback, logs)

## Claude's Behavior (Lead)

### Phase 1: Gather Facts
1. Summarize the work done in the recent research cycle:
   - Which hypotheses were tested?
   - What were the experiment results?
   - What differed from expectations?

### Phase 2: Extract Insights
2. Answer the following questions:
   - **Success**: What went well? Why?
   - **Failure**: What failed? Why?
   - **Surprise**: What was unexpected?
   - **Lessons**: What can be applied next time?
   - **Tools/Process**: Tips learned about simulators, analysis methods, etc.?

### Phase 3: Write Retrospective
3. Write `.research/retros/{date}.md`:

```markdown
# Retrospective: {date}

## Cycle Summary
- Period: ...
- Goal: ...
- Outcome: ...

## What Went Well
- ...

## What Could Improve
- ...

## Unexpected Findings
- ...

## Lessons Learned
- ...

## Suggested Next Steps
- ...
```

### Phase 4: Update Context
4. Add new insights to `.research/wisdom.md`:
   - Place under the appropriate category: **Learnings**, **Pitfalls**, or **Tool Tips**
   - Format: `- [YYYY-MM-DD] {insight content}`
   - **Never delete existing entries** (append only)

5. Update `.research/context.md` to reflect current state:
   - Update progress, next steps, etc.

6. Confirm with researcher:
   - Is a scope-mode change needed?
   - Is a research direction change needed?

## Slop Check

Record only genuine insights. No generic lessons like "try harder" or "be more careful."

## Evidence Required

Each insight must specify which experiment or event it came from.

## Must NOT

- Delete existing wisdom entries
- Record insights without specificity
- Change scope-mode without researcher approval

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Output File | Description |
|------------|-------------|
| `.research/retros/{date}.md` | Retrospective record |
| `.research/wisdom.md` | Insights added (updated) |
| `.research/context.md` | Research context updated |
