# Safety Rules

This file is auto-loaded by Antigravity as a system rule. It applies at all times.

---

## FROZEN Directories

The following directories must **never** be modified:
- `profiling/results/`
- `simulation/results/`

These directories preserve raw experimental results for reproducibility.
Always reference them read-only. Copy data elsewhere for analysis.

> Note: Claude Code enforces this via a PreToolUse hook (`check-freeze.sh`).
> Antigravity has no hook mechanism, so this rule is your only safeguard. Treat it as absolute.

---

## Scope Mode

Before starting any task, read `.research/scope-mode.txt`.
Do **not** propose actions that conflict with the current mode.

| Mode | Allowed | Must Avoid |
|------|---------|------------|
| **EXPLORATION** | Free idea exploration, literature survey | Code writing, parameter decisions |
| **REFINEMENT** | Experiment design, variable definition | New research directions |
| **FOCUSED** | Code implementation, experiment execution, debugging | Direction changes, new ideas |
| **WRITING** | Paper writing, visualization | New experiments, large code changes |

---

## 3-Strike Rule (System-Wide)

This applies to all tasks, not just `/diagnose`:
- **3 consecutive failures at the same sub-task** → Stop, summarize what you tried, and escalate to the researcher.
- Do **not** attempt a 4th approach without researcher input.
- Examples:
  - `/diagnose`: 3 hypotheses failed → escalate
  - Script implementation: 3 build-error fixes failed → escalate
  - `/analyze`: 3 attempts to explain an anomaly failed → escalate (do not fabricate explanations)

---

## Atomic Decision

When making decisions that affect the research (parameters, tools, methods):
- Confirm **one decision at a time** with the researcher.
- Do **not** bundle multiple decisions into a single proposal.
- Example: "Should we use gem5?" → confirmed → "Cache size range: 32KB–2MB?" → confirmed → next parameter.

---

## Evidence-Based Completion (Iron Law)

**Claiming work is complete without verification is dishonesty, not efficiency.**

Do not claim completion without evidence:
- Script written → include execution output (stdout/exit code)
- Validation passed → include verdict rationale (numbers, comparison table)
- Analysis done → cite specific metrics ("X increased Y%, from A to B")
- Design complete → include confirmed parameter table
- Insight recorded → specify which experiment/event it came from
- Diagnosis done → explain WHY the fix works, not just "it works now"

---

## Escalation Format (System-Wide)

When escalating (3-Strike, blocked, or insufficient information), use this format:

```
STATUS: BLOCKED | NEEDS_CONTEXT
REASON: [1-2 sentences explaining why]
ATTEMPTED: [what was tried, numbered]
RECOMMENDATION: [specific next step for the researcher]
```

---

## Confusion Score (Self-Regulation)

Track cumulative confusion during debugging and script implementation.
3-Strike catches consecutive failures; Confusion Score catches gradual drift.

| Event | Score Change |
|-------|-------------|
| Each failed fix/hypothesis | +15% |
| Each fix touching >3 files | +10% |
| After 5th parameter adjustment | +2% per additional |
| Touching files outside initial scope | +20% |
| Reverting a previous change | +15% |

- **> 25%** → STOP → Escalate to researcher with score breakdown
- **Hard cap: 10 iterations** → Stop unconditionally

---

## Decision Classification (Mechanical vs Taste)

Not every decision needs researcher input. Classify before asking:

**Mechanical** — One clearly right answer based on evidence/documentation:
- Follow existing project patterns (DRY)
- Choose the simpler of equivalent solutions (Explicit > Clever)
- Formatting, naming convention, file location choices
- → Auto-decide silently. Log in output.

**Taste** — Reasonable people could disagree:
- Research direction, parameter values, methodology trade-offs
- Anything that changes what we measure or how we interpret it
- → Ask researcher (Atomic Decision applies).

**Rule**: If unsure → treat as Taste (ask).
