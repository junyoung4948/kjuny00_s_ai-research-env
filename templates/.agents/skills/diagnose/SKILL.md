---
name: diagnose
description: >
  Failure diagnosis — systematically trace causes of experiment failures or unexpected results. 3-Strike Rule enforced.
  실패 진단, 디버깅, 에러 추적, 3-Strike Rule.
claude-model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Edit
  - AskUserQuestion
---

# /diagnose — Failure Diagnosis

## Role

- **Lead**: Claude (systematic debugging, log parsing, 3-Strike Rule)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/plans/experiment-{name}-final.md` — Experiment design
3. Relevant log files (confirm location with researcher)
4. `.research/wisdom.md` — Past failure patterns

## Claude's Behavior (Lead)

### 3-Strike Rule (Mandatory)

**Test at most 3 hypotheses sequentially.**

#### Strike 1
1. Summarize symptoms and form the most likely hypothesis.
2. Analyze logs/code/configuration to verify.
3. Record result.
   - Success → Apply fix, done
   - Failure → Strike 2

#### Strike 2
4. Reflecting on why the first hypothesis failed, form a second hypothesis.
5. Verify.
   - Success → Apply fix, done
   - Failure → Strike 3

#### Strike 3
6. Form and verify a third hypothesis.
   - Success → Apply fix, done
   - Failure → **Escalate**

#### Escalation (After 3 Strikes)
```
All 3 hypotheses failed. Additional information is needed.

Attempted hypotheses:
1. {hypothesis1} → {failure reason}
2. {hypothesis2} → {failure reason}
3. {hypothesis3} → {failure reason}

Additional information needed:
- ...

I will NOT attempt a 4th hypothesis without researcher input.
```

### Diagnosis Report Structure

```markdown
# Diagnosis Report: {name}

## Symptoms
- Occurrence: ...
- Error message: ...
- Expected vs actual result: ...

## Hypothesis Verification
### Hypothesis 1: {description}
- Rationale: ...
- Verification method: ...
- Result: CONFIRMED / REJECTED
- (If rejected) Rejection reason: ...

### Hypothesis 2: {description}
...

### Hypothesis 3: {description}
...

## Root Cause
...

## Fix Applied
...

## Lessons (add to wisdom.md)
...
```

### Iron Law: No Fix Without Root Cause

**Never apply a fix before identifying the root cause.**
- Band-aid fixes (commenting out code, adding retries, suppressing errors) are prohibited until root cause is understood.
- "It works now" is not evidence of a fix. Explain WHY it works.

### Scope Lock

During diagnosis, restrict changes to the failing component's scope:
- Do not modify files unrelated to the diagnosed issue.
- If the fix requires changes outside initial scope → escalate to researcher first.

### Confusion Score

Track cumulative confusion during this diagnosis session.
See AGENTS.md Section 8 for scoring rules.
Report current score in the Diagnosis Report if it exceeds 10%.

## FROZEN Directory Warning

Files in `profiling/results/` and `simulation/results/` cannot be modified.
Preserve original results even during debugging.

## Slop Check

Cite specific log lines or error messages. Do not speculate without evidence.

## Evidence Required

Each hypothesis must specify the log lines, error messages, or code paths that were verified.

## Must NOT

- Attempt a 4th hypothesis without escalation
- Modify FROZEN result files
- Claim a fix works without re-running the failing test

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Output File |
|------------|
| `.research/feedback/diagnosis-{name}.md` |

Add lessons learned to `.research/wisdom.md` under the appropriate category.
