---
name: brainstorm-arch
description: |
  Based on MOTIVATION.md, explore the architectural design space for a research problem
  and select a main hypothesis through interactive one-question-at-a-time dialogue.
  Proposes 2-3 approaches with trade-offs (minimal intervention / ideal architecture /
  lateral). Use after /build-motivation, before /plan-experiment.
  Outputs BASE_HYPOTHESIS.md with the selected core idea.
  Proactively suggest when the user has a MOTIVATION.md and wants to explore solutions.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - AskUserQuestion
  - WebSearch
---

# Brainstorm Architecture

Transform a well-defined research problem (MOTIVATION.md) into a focused architectural
hypothesis through structured design space exploration and interactive dialogue.

**HARD GATE**: Do NOT write any code, create simulation configs, scaffold experiments,
or plan implementation. The only output is `BASE_HYPOTHESIS.md`.
Experiment planning belongs in `/plan-experiment`.

---

## Checklist

Complete in order:

1. Load MOTIVATION.md and verify it contains a root cause chain
2. Classify the solution space (Phase 1)
3. Survey prior art relevant to the root cause (Phase 2)
4. Ask hardware constraint questions — one at a time (Phase 3)
5. Generate 2-3 architectural proposals with trade-offs (Phase 4)
6. Present proposals and select main approach interactively (Phase 5)
7. Write BASE_HYPOTHESIS.md (Phase 6)
8. Review gate — user approves or revises (Phase 7)

---

## Phase 0: Context Loading (MANDATORY)

### Step 1: Load MOTIVATION.md

```bash
PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cat $PROJ_ROOT/MOTIVATION.md 2>/dev/null || echo "NOT FOUND"
```

If MOTIVATION.md does not exist:
> MOTIVATION.md not found at `{path}`.
> Please run `/build-motivation` first to define the research problem
> before brainstorming architectural solutions.

Stop. Do not proceed.

### Step 2: Extract Key Constraints from MOTIVATION.md

Before doing anything else, explicitly record these four elements from MOTIVATION.md:

1. **Root cause** (the exact hardware-workload mismatch)
2. **Target system** (GPU model, DRAM type, PIM configuration)
3. **Bottleneck metric** (the number that quantifies the problem — e.g., "0.9% BW util")
4. **Open questions** (Section 5 of MOTIVATION.md — these anchor the design space)

### Step 3: Survey Existing Architecture Notes in Codebase

```bash
# Check for prior design docs or hypothesis files
ls -t $PROJ_ROOT/.research/ 2>/dev/null | head -10
find $PROJ_ROOT -name "BASE_HYPOTHESIS*.md" -o -name "*hypothesis*.md" 2>/dev/null | head -5
# Find any architecture notes
find $PROJ_ROOT -name "*.md" | xargs grep -l -i \
  "architecture\|hypothesis\|design.*space\|approach" 2>/dev/null | grep -v MOTIVATION | head -8
```

If prior BASE_HYPOTHESIS.md files exist, note them: "Prior hypothesis on file — {title}.
Should we revise the existing hypothesis or start a new design space exploration?"

---

## Phase 1: Solution Space Classification

Classify the solution space BEFORE generating ideas. This prevents premature convergence
on the first approach that comes to mind.

Based on the root cause extracted in Phase 0, classify which dimension the solution
targets. State your classification explicitly, then confirm with the user:

Via AskUserQuestion:
> Based on MOTIVATION.md, the root cause is: **[root cause from Phase 0]**
>
> The solution space appears to target: **[your classification — pick one below]**
>
> Does this classification seem right?
> - **A) Data placement/movement** — where data lives, how it migrates between memory tiers
> - **B) Execution scheduling** — when and where computation happens (GPU vs PIM vs CPU)
> - **C) Memory access pattern transformation** — restructure how the workload accesses memory
> - **D) Hardware micro-architecture** — row buffer policy, on-chip buffers, DRAM timing
> - **E) Algorithm–hardware co-design** — change the algorithm to match hardware constraints

If the user disagrees, update your classification and proceed with theirs.

This classification determines which architectural primitives to consider in Phase 4.

---

## Phase 2: Prior Art Survey

Before generating novel proposals, understand what has already been tried.
This prevents proposing approaches that are already prior art without differentiation.

### Step 1: Codebase Search

```bash
# Find any literature references already in the project
grep -r -i "PIM\|near.memory\|in.memory\|processing.near\|HBM\|speculative\|roofline" \
  $PROJ_ROOT --include="*.md" --include="*.txt" 2>/dev/null | head -20
find $PROJ_ROOT -name "*.bib" -o -name "*.pdf" 2>/dev/null | head -5
```

### Step 2: Web Search (if available)

Use generalized category terms — never the user's specific hypothesis wording.

Search for:
- `"[root cause keyword] architecture solution [current year]"` — what recent work addresses this
- `"[target hardware type] [workload class] memory optimization"` — system-level approaches
- `"[bottleneck mechanism] near-memory computing"` — compute-near-data approaches

Read the top 2-3 results. For each result, record:
- **What it does**: core mechanism in one sentence
- **What it does NOT do**: why our root cause is not fully addressed

If WebSearch is unavailable, proceed with in-distribution knowledge and note:
"Prior art survey skipped — no WebSearch available."

### Step 3: Enumerate Relevant Architectural Primitives

Based on the solution space classification (Phase 1), identify which primitives are
applicable to the root cause. Document this as context for Phase 4:

| Primitive | Description | Applicable? | Reason |
|-----------|-------------|-------------|--------|
| Prefetching | Predict and hide memory latency | [Y/N] | [why] |
| PIM offload | Move computation to memory side | [Y/N] | [why] |
| Tiling/blocking | Restructure access for cache reuse | [Y/N] | [why] |
| Async execution | Overlap compute and memory ops | [Y/N] | [why] |
| Access pattern reorder | Change order of memory accesses | [Y/N] | [why] |
| Approximate compute | Trade accuracy for access regularity | [Y/N] | [why] |

---

## Phase 3: Hardware Constraint Dialogue

Ask these questions **ONE AT A TIME** via AskUserQuestion.
**Never combine two questions in one message.**
The answer to each question constrains the design space before the next question.

The goal: arrive at constraints tight enough to rule out unworkable approaches and
highlight the promising region.

### Q1: Hardware Budget
> Given the root cause is **[root cause]**, what hardware modifications are in scope?
>
> A) **Software-only** — must work on existing DRAM+PIM hardware with no HW changes
> B) **Firmware/ISA extension** — can add new DRAM commands or PIM microcode
> C) **Micro-architectural** — can modify row buffer policy, add small SRAM buffers
> D) **Full co-design** — willing to modify DRAM/PIM architecture if justified by gains
>
> *Why this matters*: A software-only constraint eliminates all approaches requiring
> new hardware; full co-design opens the entire design space.

*Push if vague ("whatever it takes")*:
"If a software-only solution recovers 80% of the lost bandwidth, is that acceptable?
What is the minimum speedup that justifies hardware modifications?"

### Q2: Algorithm Flexibility
> The bottleneck is in **[specific LLM operation from MOTIVATION.md]**.
> How much can we change the algorithm?
>
> A) **Fixed semantics** — must produce bit-identical output (no approximation)
> B) **Approximate acceptable** — can trade small quality loss (< X% perplexity) for speed
> C) **Restructurable** — can reorder, tile, or batch operations if output is equivalent
> D) **Algorithm co-design** — willing to change the algorithm structure fundamentally

*Push if selecting B*: "What is the acceptable quality budget? 0.1% perplexity? 1%?
Has this been evaluated on your target model and task?"

*Push if selecting D*: "At what point does the algorithm change make this a pure ML paper
rather than a computer architecture paper? We need the contribution to be architectural."

### Q3: Why Not the Obvious Solution?
> The most natural response to **[root cause]** would be:
> **[state the obvious approach — e.g., "use a larger cache to absorb the working set"]**
>
> Why is that NOT sufficient for our problem?
> What specific aspect of the root cause does it fail to address?

*This is the most important question — the answer IS your contribution gap.*

*Push if the answer is vague ("doesn't scale well")*:
"Doesn't scale in what dimension — capacity, bandwidth, latency, or energy?
By how much does it fall short? Can you estimate the gap quantitatively?"

### Q4: Complexity vs. Gain
> What is the acceptable implementation complexity for this research?
>
> - **Small** (modify existing CUDA kernel, ~1 week of implementation)
> - **Medium** (new scheduling layer or simulator extension, ~1 month)
> - **Large** (new hardware module in PIMSimulator, ~1 semester)
>
> And: what is the **minimum speedup** that justifies this work?
> (e.g., "2× end-to-end latency reduction", "10× attention throughput")

### Q5: Evaluability
> What simulation infrastructure exists to evaluate an architectural solution?
>
> A) **PIMSimulator modification** — can model the proposed change directly in the simulator
> B) **CUDA kernel approximation** — can write a kernel that approximates the behavior
> C) **Analytical model only** — can model with Roofline/queuing theory (no simulator change)
> D) **Full system simulation needed** — requires extending beyond current infrastructure
>
> *Why this matters*: An idea that cannot be evaluated in the available infrastructure
> belongs in future work, not the main contribution.

---

## Phase 4: Generate 2-3 Architectural Proposals

After the Phase 3 dialogue, synthesize exactly 2 or 3 distinct architectural approaches.
Use the constraints gathered to eliminate infeasible ideas before listing proposals.

**Mandatory structure for proposals:**
- **One** must be the "minimal intervention" (fewest changes, fastest to evaluate)
- **One** must be the "ideal architecture" (best theoretical performance, most principled)
- **One** (optional) may be a "lateral approach" (different framing of the root cause —
  attacks a different point in the causal chain)

Present each approach using this format:

```
APPROACH A: [Short Name] — Minimal Intervention
  Core Idea:        [1 sentence: what architectural mechanism is introduced?]
  Mechanism:        [2-3 sentences: how does it work at the component level?]
  Root Cause Link:  [Which step in the MOTIVATION.md causal chain does this break?]
  Hardware Change:  [What must be modified — kernel, scheduler, DRAM ISA, micro-arch?]
  Effort:           [S / M / L]
  Evaluability:     [Easy / Medium / Hard in PIMSimulator or CUDA]
  Expected Gain:    [Specific estimate WITH reasoning:
                     "BW utilization improves from Z% to ~Y% because row miss rate drops
                      from 95% to ~40% due to [mechanism]"]
  Key Risk:         [What specific condition could cause this to fail or underperform?]
  Prior Work Delta: [How does this differ from [paper/approach]?]

APPROACH B: [Short Name] — Ideal Architecture
  [same structure]

APPROACH C: [Short Name] — Lateral Approach  (include only if meaningfully different)
  [same structure]
```

**RECOMMENDATION**: Approach [X] because [one-sentence technical reasoning grounded
in the root cause and the constraints collected in Phase 3].

### Anti-sycophancy rules for proposals:
- NEVER say "this could work" → say "this works IF AND ONLY IF [specific condition]"
- NEVER list an expected gain without the mechanism (why does the gain occur?)
- NEVER skip "Key Risk" — every architectural change has at least one failure mode
- If the user's preferred approach has a fatal flaw, name it directly:
  "This approach does not address [specific causal step] because [reason]"
- If a gain estimate relies on a key assumption, label it explicitly:
  "This assumes row miss rate is the dominant factor; if bank conflicts dominate, the gain drops to ~Nx"

---

## Phase 5: Interactive Approach Selection

Present proposals via AskUserQuestion:

> Here are [N] architectural approaches for the root cause in MOTIVATION.md:
>
> **A) [Approach A name]**: [1-line summary + expected gain]
> **B) [Approach B name]**: [1-line summary + expected gain]
> **C) [Approach C name]**: [1-line summary + expected gain] (if applicable)
> **D) Hybrid**: combine [A+B] or [A+C] — specify the combination
>
> Which approach best aligns with your research goals and timeline?

After selection, ask exactly ONE follow-up (the most important architectural question):

> For **[selected approach]**, complete this sentence:
>
> "Our key insight is that **[root cause mechanism]** can be addressed by **[proposed mechanism]**,
> which works because **[hardware-level reason why this breaks the causal chain]**."
>
> Your answer to this becomes the core claim of BASE_HYPOTHESIS.md.

---

## Phase 6: Write BASE_HYPOTHESIS.md

```bash
PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
DATE=$(date +%Y-%m-%d)
```

Write `$PROJ_ROOT/BASE_HYPOTHESIS.md`:

```markdown
# Architectural Hypothesis

Generated by /brainstorm-arch on {date}
Based on: MOTIVATION.md (root cause: {one-line root cause})

## Selected Approach: {approach name and type — Minimal/Ideal/Lateral}

## Core Claim

**Root Cause** (from MOTIVATION.md):
{one-sentence: the fundamental hardware-workload mismatch}

**Proposed Solution**:
We propose **[mechanism name]** that addresses [root cause] by [how it changes the
hardware behavior], which existing approaches cannot do because [gap statement].

**Key Insight**:
{The "aha" from Phase 5 follow-up — why this mechanism breaks the causal chain
at the right point}

## Mechanism

{3-5 sentences describing how the proposed architecture works at the component level.
Be specific about which hardware component is modified and what its new behavior is.}

### Architectural Changes Required

| Component | Current Behavior | Proposed Change | Justification |
|-----------|-----------------|-----------------|---------------|
| [e.g., DRAM row buffer policy] | [current] | [proposed] | [addresses which causal step] |
| [e.g., PIM scheduler] | [current] | [proposed] | [addresses which causal step] |

## Expected Performance Improvement

| Metric | Baseline (from MOTIVATION.md) | Projected | Reasoning |
|--------|-------------------------------|-----------|-----------|
| [bottleneck metric] | [measured] | [projected] | [mechanism] |
| [secondary metric] | [measured] | [projected] | [mechanism] |

**Headline claim** (for paper abstract):
"[Approach name] achieves [Nx] improvement in [metric] by [mechanism],
addressing [root cause] in [target system]."

## Alternatives Considered and Rejected

### [Approach that was NOT selected]
**Reason rejected**: {specific technical reason tied to a step in the causal chain}

### [Second rejected approach, if applicable]
**Reason rejected**: ...

## Key Assumptions

1. {Assumption that must hold for the gain estimate to be valid}
2. {Hardware assumption about the target system}
3. {Workload assumption about the scope of applicability}

## Open Questions for /plan-experiment

1. {Specific unknown: parameter range, threshold, interaction effect}
2. {Sensitivity analysis needed: "how does gain change as sequence length varies?"}
3. {Corner case to validate: "does the approach degrade for short sequences?"}

## Implementation Complexity

**Effort estimate**: {S / M / L / XL}
**Critical path**: {what needs to exist first — simulator extension? kernel? analytical model?}
**Primary evaluation vehicle**: {PIMSimulator modification | CUDA kernel | analytical model}

---
*Proceed to /plan-experiment to design the evaluation methodology.*
*Proceed to /analytical-model if a Roofline or queuing model should be built first.*
```

---

## Phase 7: Review Gate

Present BASE_HYPOTHESIS.md via AskUserQuestion:

> BASE_HYPOTHESIS.md has been written to `{path}`.
>
> Please review the core claim and mechanism.
>
> A) **Approve** — hypothesis is correct, proceed to `/plan-experiment`
> B) **Revise approach** — return to Phase 4 to reconsider the proposals
> C) **Revise a section** — specify which section needs changes
> D) **Start over** — the root cause in MOTIVATION.md needs updating first (re-run `/build-motivation`)

---

## Important Rules

- **One question at a time** (Phase 3): Never batch two questions into one AskUserQuestion.
- **Root cause linkage mandatory**: Every proposed approach must state which causal step
  in MOTIVATION.md it breaks. An approach with no causal link is not an architectural contribution.
- **Mechanism over assertion**: "It will be faster because it reduces misses" is not sufficient.
  Require: "Row miss rate drops from 95% to ~40% because [specific mechanism]."
- **No implementation details**: Design the idea, not the code. No CUDA kernel pseudocode,
  no simulator config parameters, no experiment scripts.
- **Gain estimates must show reasoning**: A table of "Baseline → Projected" with blank "Reasoning"
  is not acceptable.
- **The HARD GATE is absolute**: Even if the user says "just code it," do not proceed to
  implementation until BASE_HYPOTHESIS.md is approved.
