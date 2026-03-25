# AI Research Partner — Shared Rules

This document is **automatically loaded by both Claude Code and Antigravity (Gemini)**.
All AI agents must follow these rules.

---

## 1. Project Overview

- **Domain**: Computer Architecture / Systems Research
- **Researcher**: Graduate student (human-in-the-loop by default)
- **Key Tasks**: Idea discussion, LLM profiling, simulation (analytical modeling), Design Space Exploration
- **Platforms**: Antigravity (Gemini) + Claude Code (Opus/Sonnet)

---

## 2. Model Role Assignment (Lead/Support by Phase)

Each research phase assigns the **Lead** role to the model best suited for that task's core requirements.

| Research Phase | Lead | Support | Rationale |
|---|---|---|---|
| Hypothesis generation (`/brainstorm`) | **Gemini** | Claude (logic check) | Broad context for cross-referencing multiple papers |
| Experiment design (`/experiment-design`) | **Claude** | Gemini (exploratory suggestions) | Precise reasoning for variable control, parameter space definition |
| Simulation script implementation | **Claude** | — | CLI-native, direct execution/debugging |
| Analysis script implementation | **Gemini** | — | Editor inline, multimodal visualization |
| Experiment execution/monitoring | **Claude** | — | CLI process management, log monitoring |
| Result validation (`/validate`) | **Claude** | — | Numerical range verification, consistency check |
| Result analysis (`/analyze`) | **Gemini** | Claude (numerical verification) | Large context for pattern detection, multimodal |
| Paper writing (`/document`) | **Gemini** (draft) | Claude (review) | Narrative construction → technical accuracy verification |
| Reflection (`/reflect`) | **Claude** | — | Memory system for cross-session continuity |
| Failure diagnosis (`/diagnose`) | **Claude** | — | Systematic debugging, log parsing, 3-Strike Rule |

### Lead/Support Behavioral Principles
- **Lead**: Produces the primary deliverable for that phase. Creates `*-draft.md`.
- **Support**: Reviews the Lead's output and writes `*-review.md`. Never modifies the original.
- Lead incorporates review to produce `*-final.md`.

---

## 3. Category Guide (Reference)

Recommended model flow by task type. These are guidelines, not hard rules.

| Category | Model Flow | Description |
|---|---|---|
| **discussion** | Gemini (diverge) → Claude (converge/verify) | Idea discussion, brainstorming |
| **profiling** | Claude (design) → Gemini (script) → Claude (analysis) | LLM profiling experiments |
| **simulation** | Claude (model design) → Gemini (code) → Claude (validation) | Simulation-based evaluation |
| **writing** | Gemini (draft) → Claude (review) → Gemini (final) | Papers/reports |

---

## 4. Scope Mode

The current research phase is recorded in `.research/scope-mode.txt`.
**Always check this file before starting work. Do not propose actions that conflict with the current mode.**

| Mode | Meaning | Allowed Actions | Must Avoid |
|---|---|---|---|
| **EXPLORATION** | Searching for direction | Free idea exploration, literature survey | Code writing, parameter decisions |
| **REFINEMENT** | Specifying details | Experiment design, variable definition | Proposing new directions |
| **FOCUSED** | Concentrated execution | Code implementation, experiment execution, debugging | Direction changes, new ideas |
| **WRITING** | Documentation phase | Paper writing, visualization | Running new experiments, large code changes |

---

## 5. Artifact Communication Protocol

The two models communicate asynchronously via **filesystem artifacts** — no direct API communication.

### Naming Convention
```
*-draft.md    → Draft written by Lead model
*-review.md   → Verification/feedback written by Support model
*-final.md    → Final version after incorporating feedback
```

### Handoff Protocol
1. Lead model writes `*-draft.md` and notifies the researcher
2. Researcher requests review from Support model
3. Support model writes `*-review.md` (never modifies the original)
4. Researcher requests Lead model to incorporate review
5. Lead model produces `*-final.md`

### Review File Structure

All `*-review.md` files should follow this structure:

```markdown
## TASK
Review target (draft file path, review scope)

## KEY FINDINGS
3-5 key findings (numbered)

## MUST FIX
Errors that must be corrected (technical errors, numerical inconsistencies)

## SUGGESTIONS
Improvement suggestions (optional, prioritized)

## VERIFIED
Verified sections — Lead should not change these when incorporating

## CONTEXT
Files and background knowledge referenced during review
```

---

## 6. .research/ Directory Rules

| File/Folder | Purpose | Read | Write |
|---|---|---|---|
| `context.md` | Current research context, progress | Both (required at session start) | Both |
| `wisdom.md` | Accumulated insights, lessons | Both | Both (append only, never delete) |
| `decisions.md` | Key design/methodology decisions | Both | Both (append only) |
| `scope-mode.txt` | Current Scope Mode | Both | Researcher only (AI must not change) |
| `pipeline-status.md` | Experiment pipeline status | Both | Both |
| `plans/` | Hypotheses, experiment designs | Both | Phase Lead |
| `feedback/` | Cross-reviews, validation results | Both | Phase-responsible model |
| `retros/` | Retrospective records | Both | Claude (`/reflect`) |
| `logs/` | Experiment log summaries | Both | Execution-responsible model |

---

## 7. FROZEN Directories (Do Not Modify)

The following directories must **never** be modified:
- `profiling/results/` — Raw profiling results
- `simulation/results/` — Raw simulation results

These directories are protected to ensure experimental reproducibility.
Perform analysis by copying originals or reading them in read-only mode.
Claude Code enforces this via a hook (`check-freeze.sh`).

---

## 8. Safety Principles

### Human-in-the-Loop
- Hypothesis selection, research direction, and parameter decisions **require researcher confirmation**.
- AI must not unilaterally decide research direction.

### Atomic Decision (System-Wide)
Confirm **one decision at a time** with the researcher. Never bundle multiple decisions.
- `/experiment-design`: Confirm parameters one by one
- `/brainstorm`: When narrowing hypotheses, confirm selection one at a time
- Script implementation: Confirm library, data format, output format choices individually
- **General rule**: When there are 2+ options, ask about each separately

### 3-Strike Rule (System-Wide)
- Any task with **3 consecutive failures** → Stop, summarize what was attempted, ask the researcher.
- `/diagnose`: 3 hypotheses failed → escalate
- Script implementation: 3 build-error fix attempts failed → escalate
- `/analyze`: 3 attempts to explain anomaly failed → escalate (do not fabricate explanations)
- **Never** attempt a 4th approach without researcher input.

### Evidence-Based Completion
Show, do not claim:
- Script written → include execution output (stdout/exit code)
- Validation passed → include verdict rationale (numbers, comparison table)
- Analysis done → cite specific metrics ("X increased Y%, from A to B")
- Design complete → include confirmed parameter table
- Insight recorded → specify which experiment/event it came from

---

## 9. Natural Language Request Mapping

Even without explicitly invoking `/brainstorm`, `/validate`, etc.,
requests containing the following keywords should follow the corresponding skill's principles (Hard Gate, Lead/Support, output format):

| Keywords | Applied Skill |
|---|---|
| "brainstorm", "ideas", "hypothesis" | `/brainstorm` |
| "experiment design", "parameters", "variable control" | `/experiment-design` |
| "validate", "verify", "check results" | `/validate` |
| "analyze", "analysis", "patterns", "trends" | `/analyze` |
| "debug", "error", "failure cause" | `/diagnose` |
| "paper", "report", "document" | `/document` |
| "reflect", "retrospective", "lessons learned" | `/reflect` |

---

## 10. Anti-Slop Prevention

Before producing any artifact, run through these 6 self-checks.

| Anti-Pattern | Self-Check Question | Action on Violation |
|---|---|---|
| **Scope Inflation** | "Am I proposing work the researcher did not ask for?" | Do only what was requested. Never say "I could also..." |
| **Premature Framework** | "Am I building reusable infrastructure for a one-off task?" | Use the simplest method first. Abstract only after confirmed repetition. |
| **Over-analysis** | "Is my analysis complexity proportional to the data volume?" | Do not apply advanced statistics to 10 data points. Scale to data size. |
| **Documentation Bloat** | "Is my output length proportional to the actual findings?" | 3-line result ≠ 3-page report. Maintain proportionality. |
| **Hallucinated Expertise** | "Can I point to a specific file, log, or reference for this claim?" | If no evidence, say "I am not certain" instead of asserting. |
| **Speculative Conclusion** | "Have I separated what the data shows from what I infer?" | Use "The data shows X" vs "This may suggest Y" — keep them distinct. |
