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

## Evidence-Based Completion

Do not claim completion without evidence:
- Script written → include execution output (stdout/exit code)
- Validation passed → include verdict rationale (numbers, comparison table)
- Analysis done → cite specific metrics ("X increased Y%, from A to B")
- Design complete → include confirmed parameter table
- Insight recorded → specify which experiment/event it came from
