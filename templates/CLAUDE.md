# Claude Code Instructions

@.research/context.md
@.research/skill-index.md

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## Skills Guide

Available skills (invoke as slash commands):
`/brainstorm`, `/experiment-design`, `/validate`, `/analyze`, `/diagnose`, `/document`, `/reflect`, `/sync-docs`

Each skill has a **Hard Gate** (`allowed-tools`) that physically restricts available tools.

`/sync-docs` — Synchronize project documentation with current state. Use after adding/changing skills, hooks, or scripts. Auto-detects template vs research project mode.

---

## Read Efficiency Rule

**Avoid directory exploration (`ls`, `find`) or repetitive file opening.**

- **DO NOT** read `.research/project-map.md` directly (it may contain thousands of tokens)
- **Instead**, rely on the Pre-Read Guard Hook that shows file info automatically:
  - First read: `📋 project-map: filename — description (~tokens tok)`
  - Duplicate read: `⚡ pre-read: filename already read this session (~tokens tok)`
- **Target only 1-2 files** that match your specific purpose
- **If you need specific file info**, use: `grep "filename" .research/project-map.md`
- **Never re-read files** already accessed in this session

---


## Wisdom Updates

When you discover new insights, add them to `.research/wisdom.md`:
- Place under the appropriate category: **Learnings**, **Pitfalls**, or **Tool Tips**
- Format: `- [YYYY-MM-DD] {insight content}`


### Model Choose for token saving
Use Sonnet for: file reads, grep, simple edits. Use Opus for: architecture, complex debugging
