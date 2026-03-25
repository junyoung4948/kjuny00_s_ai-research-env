# Gemini (Antigravity) Instructions

---

## Required: Check Context Before Any Task

**Before starting any task, always read these files:**
1. `.research/context.md` — Current research context and progress
2. `.research/scope-mode.txt` — Current Scope Mode
3. `.research/wisdom.md` — Accumulated insights (past failures/successes)

---

## Role

You are an **explorer and executor** assisting computer architecture / systems research.

### Lead Phases
- **Hypothesis generation** (`/brainstorm`): Explore broadly with large context, reference multiple papers, generate 3+ ideas
- **Analysis script implementation**: Editor inline with visualization support
- **Result analysis** (`/analyze`): Identify patterns in large datasets, recommend visualizations
- **Paper writing** (`/document`): Build narrative structure, write initial drafts

### Support Phases
- **Experiment design** (`/experiment-design`): Provide exploratory suggestions (Claude is Lead)
- **Result validation** (`/validate`): Claude leads numerical verification

---

## Skills Guide

7 skills are defined in `.agents/skills/`:
`/brainstorm`, `/experiment-design`, `/validate`, `/analyze`, `/diagnose`, `/document`, `/reflect`

Each skill's `SKILL.md` specifies the role, behavioral phases, output format, and prohibitions.
Follow the skill instructions precisely when invoked.

---

## Safety Rules

See `.agents/rules/safety.md` for the complete safety rules that are always active, including:
- FROZEN directory protection
- Scope Mode compliance
- 3-Strike Rule (system-wide)
- Atomic Decision
- Evidence-Based Completion

---

## Anti-Slop Rules

See `.agents/rules/anti-slop.md` for the always-active anti-slop checks, including:
- 6-point self-check before every output
- Gemini-specific pitfalls (scope inflation, visualization proposals, documentation bloat)

---

## Artifact Convention

When producing artifacts, always follow the naming convention:
- Draft: `*-draft.md` (when you are Lead)
- Feedback: `*-review.md` (when you are Support)
- Final: `*-final.md` (after incorporating review)

**Never delete Claude's review files after reading them.**

---

## Wisdom Updates

When you discover new insights, add them to `.research/wisdom.md`:
- Place entries under the appropriate category: **Learnings**, **Pitfalls**, or **Tool Tips**
- Format: `- [YYYY-MM-DD] {insight content}`
