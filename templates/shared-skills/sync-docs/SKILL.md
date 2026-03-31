---
name: sync-docs
description: >
  Synchronize project documentation with current state. Auto-detects project type
  (template or research). For ai-research-env template: syncs README/GUIDE/REFERENCES.
  For research projects created with init-project.sh: syncs AGENTS.md/CLAUDE.md/GEMINI.md.
  Use after adding/changing skills, hooks, scripts, or configuration files.
claude-model: sonnet
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash
  - AskUserQuestion
---

# /sync-docs — Documentation Synchronizer

## Role

Audit documentation against current project state and apply factual
updates automatically. Ask for narrative/structural changes.

---

## Step 0: Project Type Detection

First, determine which mode to run in:

```bash
ls templates/ init-project.sh 2>/dev/null | head -5
```

```bash
ls .research/ AGENTS.md 2>/dev/null | head -5
```

- Both `templates/` directory **and** `init-project.sh` exist → **MODE: template**
  (ai-research-env template project itself)
- `.research/` directory **and** `AGENTS.md` exist → **MODE: research**
  (research project created by init-project.sh)
- Neither: use AskUserQuestion — "Which type is this project: (A) ai-research-env template, or (B) a research project created with init-project.sh?"

Output: "Detected project type: [template|research]. Proceeding with [template|research] mode."

---

## Step 1: Pre-flight — Identify What Changed

Discover all documentation files:

```bash
find . -maxdepth 3 -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" | sort
```

If git is available, identify recently changed files:

```bash
git diff --name-only HEAD~5 HEAD 2>/dev/null | head -30 || echo "(git not available — full audit mode)"
```

Classify changes into categories:
- New or modified skills
- Hook script changes
- Script changes (`scripts/`)
- Agent instruction changes (AGENTS.md, CLAUDE.md, GEMINI.md)
- Configuration changes (settings.json, init-project.sh)

Output a brief summary: "Found N documentation files to audit. Recent changes: [list]."

---

## Step 2: Per-File Audit

Read each documentation file and cross-reference against actual project state.

### Template Mode — Audit Targets

**README.md:**
- Skills table: count and content match `templates/.claude/skills/` + `templates/.agents/skills/`?
  ```bash
  ls templates/.claude/skills/
  ```
- Hook section: describes all hooks in `templates/.claude/hooks/`?
  ```bash
  ls templates/.claude/hooks/
  ```
- Shared Skills table: matches `templates/shared-skills/`?
  ```bash
  ls templates/shared-skills/
  ```
- Directory structure tree: matches actual template output structure?
- Script references: all scripts in `scripts/` are mentioned?
- Scope Mode values: still match `.research/scope-mode.txt` spec?

**docs/GUIDE.md:**
- Architecture sections: component descriptions accurate?
- 3-tier sharing model table: reflects current `templates/` layout?
- Skill descriptions: match actual SKILL.md files?
- Hook behavior descriptions: match actual hook scripts?

**docs/REFERENCES.md:**
- If new patterns were adopted from reference projects, are they documented?
- This file is relatively static — only flag if clear gaps exist.

### Research Mode — Audit Targets

**AGENTS.md:**
- Skills list in §2 (or equivalent): matches actual `.claude/skills/` contents?
  ```bash
  ls .claude/skills/
  ```
- Role/phase table: still accurate?
- Auto-Handoff section: consistent with `scripts/invoke-claude.sh` and `scripts/create-handoff.sh` existence?
  ```bash
  ls scripts/
  ```

**CLAUDE.md:**
- Skills Guide section: lists all skills available in `.claude/skills/`?
- Safety Rules section: FROZEN dir paths match `check-freeze.sh`?
  ```bash
  grep -n "FROZEN_DIRS" .claude/hooks/check-freeze.sh
  ```

**GEMINI.md:**
- Skills list: consistent with AGENTS.md?
- Role descriptions: consistent with AGENTS.md phase table?

**README.md** (if present): Read `.research/context.md` and check if README introduction is consistent.

---

## Step 3: Auto-Update (No Confirmation Needed)

Apply these changes directly:
- Skill count numbers ("9개 Skills" → "10개 Skills")
- Adding a new skill row to a table
- Updating file path references
- Fixing directory structure trees to match reality
- Updating script name references
- Fixing hook pattern tables (adding/removing patterns)

For each auto-update, output a one-line summary:
`README.md: updated skill count 9→10, added /sync-docs to skills table`

**Never auto-update:**
- Project introduction or positioning paragraphs
- Architecture design rationale
- Analysis content in REFERENCES.md
- Role descriptions or phase tables (these are design decisions)

---

## Step 4: Risky Changes (AskUserQuestion)

For each change that is not clearly factual, use AskUserQuestion with:
- Context: which file, which section
- The proposed change
- `RECOMMENDATION: [option] because [one-line reason]`
- At minimum: "A) Apply as suggested", "B) Skip — leave as-is"

Apply approved changes immediately after each answer.

---

## Step 5: Cross-Doc Consistency Check

After auditing files individually, run a cross-document pass:

### Template Mode
1. README.md skill count == number of skills in GUIDE.md skill list?
2. README.md hook descriptions consistent with GUIDE.md hook section?
3. README.md directory structure consistent with GUIDE.md Part 1 architecture?
4. Every .md file reachable from README.md? (discoverability)

### Research Mode
1. AGENTS.md skill list == CLAUDE.md Skills Guide list?
2. AGENTS.md phase/role table consistent with GEMINI.md role descriptions?
3. CLAUDE.md Safety Rules FROZEN dirs match `.claude/hooks/check-freeze.sh` `FROZEN_DIRS`?
4. CLAUDE.md handoff instructions consistent with scripts actually present in `scripts/`?

Flag any inconsistency. Auto-fix clear factual discrepancies (e.g., skill count mismatch).
Use AskUserQuestion for narrative contradictions.

---

## Step 6: Summary Output

End with a scannable health summary:

```
