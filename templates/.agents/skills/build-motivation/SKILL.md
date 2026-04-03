---
name: build-motivation
description: |
  Parse baseline simulation profiling logs, memory traces, and/or reference papers
  to define the ROOT CAUSE (not symptoms) of the research bottleneck.
  Use when you have Nsight/DRAMsim/PIMSimulator logs, application timing breakdowns,
  or survey papers and need a rigorous, quantified problem statement.
  Outputs MOTIVATION.md. Must run before /brainstorm-arch.
  Proactively suggest when the user shares profiling data, mentions a performance gap,
  or describes unexpected simulation results.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - AskUserQuestion
---

# Build Research Motivation

Transform raw profiling artifacts, simulation logs, or reference literature into a
rigorous, quantified problem statement anchored to a hardware root cause.

**HARD GATE**: Do NOT propose any architectural solutions or design ideas here.
This phase only defines *what* is wrong and *why* at the hardware level.
Architecture proposals belong in `/brainstorm-arch`.

---

## Phase 0: Input Classification (MANDATORY FIRST STEP)

Before doing anything, identify what artifacts are available.

Ask via AskUserQuestion:

> What input artifacts do you have for this motivation? (select all that apply)
>
> - **A)** Nsight Systems / Nsight Compute report (`.ncu-rep`, `.nsys-rep`, or CSV export)
> - **B)** DRAM/PIM Simulator logs (DRAMsim3, PIMSimulator output traces, `.log`)
> - **C)** Application-level profiling (timing breakdowns, bandwidth logs, custom instrumentation)
> - **D)** Reference paper(s) with key measurements (provide path or title)
> - **E)** Manual description — no files yet (you will describe the bottleneck)
>
> Also: what is the target system? (e.g., GPU+HBM2E, GPU+PIM-enabled DRAM, CPU-only)

**Routing based on answer:**
- A, B, or C → **Evidence Mode** (Phase 1A: parse files, extract metrics)
- D → **Literature Mode** (Phase 1B: parse papers, extract cited numbers)
- E → **Discovery Mode** (Phase 1C: structured elicitation)

Multiple types can be combined (e.g., A + D). Run each applicable phase in sequence.

---

## Phase 1A: Evidence Mode — Profiling Log Analysis

*Use when artifact files (A, B, or C) are available.*

### Step 1: Locate and Survey Artifacts

```bash
PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
# Find profiling outputs
find $PROJ_ROOT -name "*.log" -o -name "*.csv" -o -name "*.txt" \
  | grep -i -E "profile|trace|bench|perf|sim|nsight|dram" 2>/dev/null | head -20
find $PROJ_ROOT -name "*.ncu-rep" -o -name "*.nsys-rep" 2>/dev/null | head -10
ls -lh $PROJ_ROOT/*.log $PROJ_ROOT/*.csv 2>/dev/null | head -20
```

Survey file sizes before reading. For files > 1 MB, sample with `head`/`tail`/`grep`
rather than reading entirely. Identify format (CSV, structured log, raw text).

### Step 2: Extract Metrics by Category

Parse the following metrics in parallel — run all grep commands simultaneously:

**Memory metrics** (bandwidth utilization, cache behavior):
```bash
grep -i -E "bandwidth|GB/s|memory.*util|BW" <logfile> | head -30
grep -i -E "hit.*rate|miss.*rate|L[12].*cache|LLC|row.*hit|row.*miss" <logfile> | head -20
grep -i -E "DRAM.*access|memory.*transaction|read.*write.*ratio" <logfile> | head -20
grep -i -E "bank.*conflict|refresh|tRCD|tCAS|row.*buffer" <logfile> | head -20
```

**Compute metrics** (utilization, throughput):
```bash
grep -i -E "SM.*util|compute.*util|GPU.*util|occupancy|warp.*efficiency" <logfile> | head -20
grep -i -E "FLOP|arithmetic.*intensity|throughput|TFLOPS" <logfile> | head -20
```

**Latency metrics** (where time is spent):
```bash
grep -i -E "duration|latency|kernel.*time|elapsed|cycle" <logfile> | head -30
grep -i -E "memory.*latency|DRAM.*latency|access.*cycle|stall" <logfile> | head -20
```

### Step 3: Roofline Position Analysis

After extracting metrics, compute or estimate the operational intensity (OI):

```
Arithmetic Intensity (AI) = Total FLOPs / Total DRAM bytes transferred
```

Compare to hardware limits from specs:
- **Peak Memory Bandwidth**: HW spec (GB/s) — look up or ask user
- **Measured Memory Bandwidth**: extracted from profiling (GB/s)
- **Bandwidth Utilization**: Measured / Peak × 100%
- **Peak Compute**: HW spec (TFLOPS)
- **Measured Compute Throughput**: from profiling
- **Performance Limiter**: Is the point LEFT of the roofline ridge? → Memory-bound. RIGHT? → Compute-bound.

### Step 4: Drill Down to Specific Bottleneck

Once the limiter is identified, drill deeper:

```bash
# For DRAM simulator: identify access pattern quality
grep -i -E "row.*hit|row.*miss|bank.*conflict|page.*policy" <simlog> | head -30
# For CUDA profiling: identify memory hierarchy bottleneck
grep -i -E "global.*load|global.*store|L2.*hit|L2.*miss|DRAM.*read" <profile> | head -20
# For PIM-specific: PIM utilization
grep -i -E "PIM.*util|compute.*unit|PIM.*stall|memory.*side" <simlog> | head -20
```

Record:
- Which specific operation (attention, FFN, embedding lookup?) dominates runtime
- For memory-bound: is the bottleneck DRAM bandwidth, row hit rate, or bank conflicts?
- For compute-bound: is the bottleneck register pressure, occupancy, or warp divergence?

---

## Phase 1B: Literature Mode — Paper Analysis

*Use when reference papers (D) are available.*

Read the provided paper(s) and extract the following — write them down explicitly:

1. **Problem statement**: What does the paper identify as the bottleneck? (exact quote preferred)
2. **Key measurements**: Exact numbers cited (%, GB/s, speedup ratio, latency ms)
3. **Root cause**: What architectural or algorithmic cause is identified?
4. **Target system**: What hardware does the paper evaluate on?
5. **Remaining open problems**: What does the paper explicitly leave unsolved?

```bash
# Check for local PDF or BIB files
find $PROJ_ROOT -name "*.pdf" -o -name "*.bib" 2>/dev/null | head -10
```

After extracting from the paper, ask via AskUserQuestion:

> The paper identifies [specific bottleneck with numbers]. Does our target system
> exhibit this same bottleneck? Is there any measurement from our own baseline
> simulation that confirms or contradicts this?

If no confirmation exists, this becomes an Open Question in MOTIVATION.md Section 5.

---

## Phase 1C: Discovery Mode — Structured Elicitation

*Use when no artifact files are available (input type E).*

Ask these questions **ONE AT A TIME** via AskUserQuestion. Each question targets a
specific layer of the root cause chain. Wait for the full answer before proceeding.

**Q1: Observation** — What did you measure?
> Describe the specific performance gap in concrete numbers.
> What throughput, latency, or utilization did you measure?
> What did you expect based on hardware specs?
> Example: "Attention achieves 8 GB/s; GPU HBM2E peak is 900 GB/s."

*Push if vague*: "You said it's slow — by how much compared to theoretical peak?
What is the % utilization of the bottleneck resource?"

**Q2: Bottleneck Component** — Where is time spent?
> Which hardware component appears to be the bottleneck?
> Choices: DRAM bandwidth | Cache capacity | Compute units (SM) | Interconnect | PIM units
> What evidence (profiling output, roofline position, stall counters) leads you here?

*Push if vague*: "If DRAM is the bottleneck, what is the row hit rate?
If compute is the bottleneck, what is the SM utilization %?"

**Q3: Access Pattern** — Why is the hardware inefficient for this workload?
> Describe the memory access pattern of the bottleneck operation:
> sequential, strided, random, gather/scatter?
> What is the working set size? Does it fit in L2? In HBM?
> For attention: what is the KV-cache size at the sequence lengths you target?

**Q4: Quantified Gap** — How bad is it?
> What is the measured performance vs. theoretical peak?
> Provide the ratio: e.g., "achieving 12 GB/s out of 900 GB/s peak → 1.3% utilization"
> OR: "attention takes 73% of total inference time at sequence length 2048"

**Q5: Root Cause Hypothesis** — Why does this happen architecturally?
> What do you believe is the fundamental hardware-workload mismatch?
> Example: "KV-cache attention accesses DRAM in a scatter pattern → high row miss rate
> → DRAM row buffer thrashes → effective bandwidth collapses to <2% of peak"

---

## Phase 2: Root Cause Synthesis

After gathering evidence from Phase 1A/1B/1C, synthesize the root cause into a
**causal chain** — not just a list of symptoms.

Structure the analysis as a chain of causation:

```
SYMPTOM:    [Observable metric degradation with exact numbers]
    ↓ caused by
CAUSE 1:    [Immediate technical cause — what the workload does]
    ↓ caused by
CAUSE 2:    [Hardware response to that behavior — what the HW does wrong]
    ↓ caused by
ROOT CAUSE: [Fundamental mismatch: workload property X violates HW assumption Y]
```

**Reference example** (LLM inference KV-cache on DRAM):
```
SYMPTOM:    KV-cache attention achieves 8 GB/s / 900 GB/s = 0.9% BW utilization
    ↓
CAUSE 1:    Attention generates O(n²) gather-reads over the KV-cache (irregular pattern)
    ↓
CAUSE 2:    Irregular addresses cause >95% DRAM row miss rate, destroying row-buffer reuse
    ↓
ROOT CAUSE: KV-cache access pattern violates DRAM's implicit "locality = row reuse" assumption.
            DRAM row-buffer policy is designed for sequential/strided workloads; random KV
            access makes every access a row miss, incurring full tRCD+tCAS per word.
```

**Anti-sycophancy rules — NEVER accept:**
- "Memory is the bottleneck" without a bandwidth utilization % → demand the number
- "DRAM is inefficient" without specifying row hit/miss rate → drill deeper
- "Latency is high" without identifying which hardware stage dominates → trace the cycle breakdown
- A symptom presented as a root cause → keep asking "why does that happen?" until you reach
  a hardware constraint that cannot be pushed further without changing the architecture

---

## Phase 3: Significance & Motivation Statement

After identifying the root cause, establish *why this must be solved now*:

1. **Scale of the gap**: How far below peak? 2× below peak → incremental. 100× below peak → fundamental.
2. **Generality**: Is this workload-specific or a fundamental property of the algorithm class?
   (e.g., does this affect all transformer-based models, or only long-context?)
3. **Why the standard fix fails**: What is the obvious engineering response, and why is it
   insufficient? (e.g., "simply increasing DRAM bandwidth doesn't help because the bottleneck
   is row miss rate — 10× more bandwidth with 95% miss rate still wastes 95% of that bandwidth")
4. **Research opportunity**: What new capability or insight is needed that current solutions lack?

---

## Phase 4: Write MOTIVATION.md

```bash
PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
DATE=$(date +%Y-%m-%d)
```

Write `$PROJ_ROOT/MOTIVATION.md`:

```markdown
# Research Motivation

Generated by /build-motivation on {date}
Artifacts analyzed: {list input files, or "manual elicitation via structured questions"}
Target system: {GPU model + memory type, PIM configuration if applicable}

## 1. Observed Symptom

**Workload**: {what LLM operation / kernel was profiled}
**Hardware**: {target system}
**Measured**: {key metric(s) with exact numbers}
**Expected (peak)**: {hardware theoretical limit}
**Gap**: {measured / peak = X%}

## 2. Root Cause Analysis

### Causal Chain

```
SYMPTOM:    [metric] = [measured] vs [peak] = [X%]
    ↓
CAUSE 1:    [workload behavior]
    ↓
CAUSE 2:    [hardware response]
    ↓
ROOT CAUSE: [fundamental hardware-workload mismatch]
```

### Supporting Evidence

| Metric | Measured | Peak / Expected | Utilization |
|--------|----------|-----------------|-------------|
| DRAM Bandwidth | X GB/s | Y GB/s | Z% |
| Row Hit Rate | X% | ~90% (ideal) | — |
| SM Utilization | X% | 100% | — |
| [other] | ... | ... | ... |

Source: {log file names / paper citations}

### Key Data Points

- {Specific number 1} — source: {file:line or paper}
- {Specific number 2} — source: {file:line or paper}
- {Specific number 3} — source: {file:line or paper}

## 3. Why Standard Approaches Are Insufficient

- **Increase DRAM bandwidth**: [why this fails — e.g., miss rate means bandwidth increase is wasted]
- **Software prefetching**: [why this fails — e.g., irregular access defeats prediction]
- **Larger cache**: [why this fails — e.g., working set exceeds on-chip capacity]

## 4. Research Opportunity

**Core Claim**: The root cause is [X], and addressing it requires [Y].
No existing solution does this because [Z].

**Potential Impact**: Addressing this could recover Nx of lost [bandwidth/compute],
potentially reducing [attention/FFN/total] latency by Mx.

**Who this affects**: [Scope — all LLM inference? Long-context specifically? PIM-enabled systems?]

## 5. Open Questions for /brainstorm-arch

1. {Hardware design question — what constraint must be relaxed?}
2. {Algorithm question — what access pattern change is acceptable?}
3. {System question — what other components does a fix interact with?}

---
*Proceed to /brainstorm-arch to explore architectural solutions.*
```

---

## Phase 5: Review Gate

Present MOTIVATION.md to user via AskUserQuestion:

> MOTIVATION.md has been written to `{path}`. Please review the root cause chain.
>
> A) **Approve** — root cause is correct, proceed to `/brainstorm-arch`
> B) **Revise section** — specify which section needs changes (return to relevant phase)
> C) **Wrong root cause** — re-run Phase 1 with different artifact focus
> D) **Need more data** — specify what profiling run would clarify the root cause

---

## Important Rules

- **Root cause, not symptom**: Never accept "memory is slow" — find the specific
  hardware mechanism. Keep asking "why?" until you reach a hardware constraint.
- **Numbers required**: Every claim must have a measurement or a paper citation.
- **One question at a time** (Discovery Mode): Never batch questions.
- **No architecture proposals**: This phase only diagnoses — do not hint at solutions.
- **Causal chain mandatory**: The Symptom → Root Cause chain must be present in MOTIVATION.md.
