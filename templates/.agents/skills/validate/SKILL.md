---
name: validate
description: >
  Result validation — systematically verify numerical ranges, consistency, and reproducibility of experiment results.
  결과 검증, 수치 확인, 일관성 체크.
claude-model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# /validate — Result Validation

## Role

- **Lead**: Claude (precise reasoning for numerical range verification, consistency checks)

## Prerequisites (Required)

1. `.research/context.md` — Current research context
2. `.research/plans/experiment-{name}-final.md` — Experiment design
3. Experiment result files (confirm location with researcher)

## Claude's Behavior (Lead)

### Phase 1: Sanity Check
1. **Numerical range verification**: Are result values within physically/logically reasonable bounds?
   - e.g., Is IPC negative or unrealistically high?
   - e.g., Is energy consumption zero or infinite?
2. **Unit verification**: Are all units correct?
3. **Missing data check**: Are there any missing data points?

### Phase 2: Consistency Verification
4. **Internal consistency**: Do related metrics show consistent patterns?
   - e.g., Does memory bandwidth increase when cache miss rate increases?
5. **Baseline comparison**: Do baseline results match known values?
6. **Trend verification**: Do results follow expected trends as parameters change?

### Phase 3: Reproducibility Check
7. Do identical configurations produce results within acceptable tolerance?
8. Are random seeds fixed? (if applicable)

### Phase 4: Write Validation Report

```markdown
# Validation Report: {name}

## Validation Target
- Experiment: ...
- Result files: ...

## Sanity Check
| Item | Result | Notes |
|------|--------|-------|
| Numerical range | PASS/WARN/FAIL | ... |
| Units | PASS/WARN/FAIL | ... |
| Missing data | PASS/WARN/FAIL | ... |

## Consistency Verification
| Item | Result | Notes |
|------|--------|-------|
| Internal consistency | PASS/WARN/FAIL | ... |
| Baseline | PASS/WARN/FAIL | ... |
| Trends | PASS/WARN/FAIL | ... |

## Reproducibility
| Item | Result | Notes |
|------|--------|-------|

## Overall Verdict
- [ ] PASS — Results are trustworthy
- [ ] CONDITIONAL — Some items need further verification
- [ ] FAIL — Re-experiment or debugging needed

## Findings
...
```

## Bash Usage Restriction

Bash is allowed for **read-only purposes** only:
- Parsing result files (awk, python scripts, etc.)
- Numerical comparison/calculation
- Log inspection

**Prohibited**: Re-running experiments, modifying files, starting new processes

## FROZEN Directory Warning

`profiling/results/` and `simulation/results/` are read-only.
Copy originals for analysis or read them directly.

## Slop Check

Report only what the data shows. Do not speculate on causes.

## Evidence Required

The verdict table must include specific numbers and comparisons for each item. An empty "Notes" column is not acceptable.

## Must NOT

- Modify original result files
- Ignore anomalies without explanation
- Assign PASS verdict when CONDITIONAL or FAIL items exist

## Completion Status

End every output with one of: DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.
See AGENTS.md Section 12.

## Output

| Output File |
|------------|
| `.research/feedback/validation-{name}.md` |
