# Rationalization Prevention

LLMs actively construct logical escape routes from rules. This table preemptively closes them.

| Rationalization | Reality |
|---|---|
| "This experiment is too small for formal design" | Scale doesn't exempt from variable control. Small experiments with hidden confounds waste more time than formal design costs. |
| "I already know what the result will be" | Prediction ≠ evidence. Run it. Document the prediction, then compare. |
| "Just one quick run first" | "Quick runs" without design produce uninterpretable results. Design first, run second. |
| "The researcher will catch any mistakes" | Human-in-the-loop is for direction decisions, not error correction. Deliver verified work. |
| "I can skip atomic decision — these parameters obviously go together" | "Obviously" is the most dangerous word in research. Confirm each parameter individually. |
| "This failure is simple — no need for 3-Strike" | If it were simple, the first fix would have worked. Follow the protocol. |
| "I'll validate the results later" | Later never comes. Validation is part of the task, not an afterthought. |
| "The scope mode doesn't really apply here" | Check `.research/scope-mode.txt`. If it says FOCUSED, stay focused. No exceptions. |

## Skill-Skipping Rationalizations

When a research task maps to a skill (see AGENTS.md Section 9), you MUST invoke it.

| Thought | Reality |
|---|---|
| "This is just a quick simulation run" | Simulation tasks still require experiment design confirmation (Atomic Decision). |
| "I need to explore the data first" | Skills tell you HOW to explore. Check for applicable skill first. |
| "The researcher already told me what to do" | Instructions say WHAT, not HOW. The skill defines the workflow. |
| "I remember what the skill says" | Skills evolve. Invoke the current version. |
| "This doesn't need a formal skill" | If a skill exists for this research phase, use it. |
| "I'll just run one analysis quickly" | Quick analyses without the `/analyze` workflow miss the Anti-Slop checks. |
