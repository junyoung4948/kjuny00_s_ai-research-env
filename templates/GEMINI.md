# Gemini (Antigravity/GEMINI CLI) Instructions

@.research/context.md
@AGENTS.md

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Gemini-Specific Intent Gate Constraints

<GEMINI_INTENT_GATE_ENFORCEMENT>
**YOU MUST CLASSIFY INTENT BEFORE ACTING. NO EXCEPTIONS.**

**Your failure mode:** You tend to skip broad intent classification and jump straight to executing commands or writing code.
You MUST NOT write code, invoke tools, or attempt to solve the problem before explicitly stopping to classify what kind of work the user actually wants.

**MANDATORY FIRST OUTPUT — before ANY tool call:**
```
I detect [TYPE] intent — [REASON].
My approach: [WHICH SKILL TO INVOKE OR NEXT STEPS].
```

**IF YOU SKIPPED THIS:** STOP. Do it now. Your next tool call is INVALID without it.
</GEMINI_INTENT_GATE_ENFORCEMENT>

## Instruction Priority

skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## Read Efficiency Rule

**Avoid directory exploration (`ls`, `find`) or repetitive file opening.**

- **DO NOT** read `.research/project-map.md` directly (it may contain thousands of tokens)
- **Target only 1-2 files** that match your specific purpose
- **If you need file info**, use: `grep "filename" .research/project-map.md` for specific searches
- **Avoid re-reading files** - check if you've already accessed them in this session
- **Note**: Claude Code has automatic duplicate detection hooks, but Antigravity relies on manual discipline

---

## Wisdom Updates


When you discover new insights, add them to `.research/wisdom.md`:
- Place under the appropriate category: **Learnings**, **Pitfalls**, or **Tool Tips**
- Format: `- [YYYY-MM-DD] {insight content}`
