# Project Map
> Generated: 2026-03-31T20:57:58+09:00 | Files: 86


## .
- `init-project.sh` — Re-exec with bash if invoked via sh/dash (which ignores the shebang) (~3676 tok)
- `README.md` — Project overview (~4781 tok)
- `setup.sh` — setup.sh — 전역 설정 설치 (~1176 tok)

## docs
- `GUIDE.md` (~9906 tok)
- `REFERENCES.md` (~1833 tok)

## global/claude
- `CLAUDE.md` — Claude Code instructions (~154 tok)
- `settings.json` — Claude Code settings (~245 tok)

## global/gemini
- `AGENTS.md` — Agent configuration (~103 tok)
- `GEMINI.md` — Gemini agent instructions (~151 tok)

## scripts
- `generate-project-map.sh` — generate-project-map.sh — Build .research/project-map.md (~3108 tok)
- `generate-skill-index.sh` — generate-skill-index.sh — Build .research/skill-index.md (~1332 tok)
- `install-cron.sh` — install-cron.sh — Register sync-models.py as an hourly cron job (~253 tok)
- `sync-models.py` — sync-models.py — Dynamic Model Selection for Claude Code (~1687 tok)

## templates
- `AGENTS.md` — Agent configuration (~4738 tok)
- `CLAUDE.md` — Claude Code instructions (~520 tok)
- `GEMINI.md` — Gemini agent instructions (~381 tok)

## templates/shared-skills/bash-pro
- `SKILL.md` — Master of defensive Bash scripting for production automation, CI/CD (~4592 tok)

## templates/shared-skills/doc-coauthoring
- `SKILL.md` — Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks. (~3953 tok)

## templates/shared-skills/gdb-cli
- `SKILL.md` — GDB debugging assistant for AI agents - analyze core dumps, debug live processes, investigate crashes and deadlocks with source code correlation (~1354 tok)

## templates/shared-skills/git-advanced-workflows
- `SKILL.md` — Master advanced Git techniques to maintain clean history, collaborate effectively, and recover from any situation with confidence. (~2388 tok)

## templates/shared-skills/matplotlib
- `SKILL.md` — Matplotlib is Python's foundational visualization library for creating static, animated, and interactive plots. (~2799 tok)

## templates/shared-skills/pdf
- `forms.md` (~2963 tok)
- `reference.md` (~4173 tok)
- `SKILL.md` — Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill. (~2018 tok)

## templates/shared-skills/pdf/scripts
- `check_bounding_boxes.py` (~792 tok)
- `check_fillable_fields.py` (~76 tok)
- `convert_pdf_to_images.py` (~288 tok)
- `create_validation_image.py` (~359 tok)
- `extract_form_field_info.py` (~1228 tok)
- `extract_form_structure.py` — Extract form structure from a non-fillable PDF. (~1127 tok)
- `fill_fillable_fields.py` (~1091 tok)
- `fill_pdf_form_with_annotations.py` (~924 tok)

## templates/shared-skills/pptx
- `editing.md` (~1721 tok)
- `pptxgenjs.md` (~3204 tok)
- `SKILL.md` — Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx file (even if the extracted content will be used elsewhere, like in an email or summary); editing, modifying, or updating existing presentations; combining or splitting slide files; working with templates, layouts, speaker notes, or comments. Trigger whenever the user mentions \"deck,\" \"slides,\" \"presentation,\" or references a .pptx filename, regardless of what they plan to do with the content afterward. If a .pptx file needs to be opened, created, or touched, use this skill. (~2295 tok)

## templates/shared-skills/pptx/scripts
- `add_slide.py` — Add a new slide to an unpacked PPTX directory. (~1963 tok)
- `clean.py` — Remove unreferenced files from an unpacked PPTX directory. (~2738 tok)
- `__init__.py` (~0 tok)
- `thumbnail.py` — Create thumbnail grids from PowerPoint presentation slides. (~2510 tok)

## templates/shared-skills/pptx/scripts/office
- `pack.py` — Pack a directory into a DOCX, PPTX, or XLSX file. (~1426 tok)
- `soffice.py` — Helper for running LibreOffice (soffice) in environments where AF_UNIX (~1514 tok)
- `unpack.py` — Unpack Office files (DOCX, PPTX, XLSX) for editing. (~1157 tok)
- `validate.py` — Command line tool to validate Office document XML files against XSD schemas and tracked changes. (~1048 tok)

## templates/shared-skills/pptx/scripts/office/helpers
- `__init__.py` (~0 tok)
- `merge_runs.py` — Merge adjacent runs with identical formatting in DOCX. (~1590 tok)
- `simplify_redlines.py` — Simplify tracked changes by merging adjacent w:ins or w:del elements. (~1644 tok)

## templates/shared-skills/pptx/scripts/office/validators
- `base.py` — Base validator with common validation logic for document files. (~9328 tok)
- `docx.py` — Validator for Word document XML files against XSD schemas. (~4678 tok)
- `__init__.py` — Validation modules for Word document processing. (~96 tok)
- `pptx.py` — Validator for PowerPoint presentation XML files against XSD schemas. (~2806 tok)
- `redlining.py` — Validator for tracked changes in Word documents. (~2548 tok)

## templates/shared-skills/python-pro
- `SKILL.md` — Master Python 3.12+ with modern features, async programming, performance optimization, and production-ready practices. Expert in the latest Python ecosystem including uv, ruff, pydantic, and FastAPI. (~1821 tok)

## templates/shared-skills/seaborn
- `SKILL.md` — Seaborn is a Python visualization library for creating publication-quality statistical graphics. Use this skill for dataset-oriented plotting, multivariate analysis, automatic statistical estimation, and complex multi-panel figures with minimal code. (~4889 tok)

## templates/shared-skills/skill-creator
- `SKILL.md` — Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. (~8292 tok)

## templates/shared-skills/skill-creator/agents
- `analyzer.md` (~2594 tok)
- `comparator.md` (~1821 tok)
- `grader.md` (~2262 tok)

## templates/shared-skills/skill-creator/assets
- `eval_review.html` (~2016 tok)

## templates/shared-skills/skill-creator/eval-viewer
- `generate_review.py` — Generate and serve a review page for eval results. (~4675 tok)
- `viewer.html` (~12856 tok)

## templates/shared-skills/skill-creator/references
- `schemas.md` (~3015 tok)

## templates/shared-skills/skill-creator/scripts
- `aggregate_benchmark.py` — Aggregate individual run results into benchmark summary statistics. (~4110 tok)
- `generate_report.py` — Generate an HTML report from run_loop.py output. (~3670 tok)
- `improve_description.py` — Improve a skill description based on eval results. (~3176 tok)
- `__init__.py` (~0 tok)
- `package_skill.py` — Skill Packager - Creates a distributable .skill file of a skill folder (~1209 tok)
- `quick_validate.py` — Quick validation script for skills - minimal version (~1134 tok)
- `run_eval.py` — Run trigger evaluation for a skill description. (~3275 tok)
- `run_loop.py` — Run the eval + improve loop until all pass or max iterations reached. (~3887 tok)
- `utils.py` — Shared utilities for skill-creator scripts. (~474 tok)

## templates/shared-skills/xlsx
- `SKILL.md` — Use this skill any time a spreadsheet file is the primary input or output. This means any task where the user wants to: open, read, edit, or fix an existing .xlsx, .xlsm, .csv, or .tsv file (e.g., adding columns, computing formulas, formatting, charting, cleaning messy data); create a new spreadsheet from scratch or from other data sources; or convert between tabular file formats. Trigger especially when the user references a spreadsheet file by name or path — even casually (like \"the xlsx in my downloads\") — and wants something done to it or produced from it. Also trigger for cleaning or restructuring messy tabular data files (malformed rows, misplaced headers, junk data) into proper spreadsheets. The deliverable must be a spreadsheet file. Do NOT trigger when the primary deliverable is a Word document, HTML report, standalone Python script, database pipeline, or Google Sheets API integration, even if tabular data is involved. (~2865 tok)

## templates/shared-skills/xlsx/scripts
- `recalc.py` — Excel Formula Recalculation Script (~1652 tok)

## templates/shared-skills/xlsx/scripts/office
- `pack.py` — Pack a directory into a DOCX, PPTX, or XLSX file. (~1426 tok)
- `soffice.py` — Helper for running LibreOffice (soffice) in environments where AF_UNIX (~1514 tok)
- `unpack.py` — Unpack Office files (DOCX, PPTX, XLSX) for editing. (~1157 tok)
- `validate.py` — Command line tool to validate Office document XML files against XSD schemas and tracked changes. (~1048 tok)

## templates/shared-skills/xlsx/scripts/office/helpers
- `__init__.py` (~0 tok)
- `merge_runs.py` — Merge adjacent runs with identical formatting in DOCX. (~1590 tok)
- `simplify_redlines.py` — Simplify tracked changes by merging adjacent w:ins or w:del elements. (~1644 tok)

## templates/shared-skills/xlsx/scripts/office/validators
- `base.py` — Base validator with common validation logic for document files. (~9328 tok)
- `docx.py` — Validator for Word document XML files against XSD schemas. (~4678 tok)
- `__init__.py` — Validation modules for Word document processing. (~96 tok)
- `pptx.py` — Validator for PowerPoint presentation XML files against XSD schemas. (~2806 tok)
- `redlining.py` — Validator for tracked changes in Word documents. (~2548 tok)

## tests
- `test-check-careful.sh` — test-check-careful.sh — Unit tests for check-careful.sh hook (~862 tok)
- `test-check-freeze.sh` — test-check-freeze.sh — Unit tests for check-freeze.sh hook (~822 tok)
