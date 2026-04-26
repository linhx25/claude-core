# Requirements Spec — Task-Specific Rubric System

**Date:** 2026-04-26
**Branch:** main
**Status:** DRAFT → APPROVED → IN PROGRESS → DONE

---

## Task Summary

Replace the current universal-but-biased `/score` rubric with a task-specific
rubric template system. Two pre-built libraries (`academic/` and `coding/`)
ship with the core; new task types use a 4-phase comprehensive interview to
build their rubric on the fly. `/critique` reads task-specific attack surface
from the same templates, eliminating drift between scoring and adversarial
review.

The framework's spine (six-layer architecture, non-negotiables, hooks) does
not change. Only the quality gate and adversarial review layers get sharper.

---

## Requirements

### MUST (non-negotiable)

| # | Requirement | Clarity |
|---|-------------|---------|
| M1 | Replace fixed rubric in `score.md` with template-loading mechanism keyed on file extension | CLEAR |
| M2 | Add `templates/rubrics/academic/` and `templates/rubrics/coding/` directories with user-provided hand-tuned libraries | BLOCKED — user must provide libraries |
| M3 | Define rubric file format: frontmatter (name, applies_to, description) + dimensions section (4 task-tuned dims with weights and calibration anchors) + critique attack surface section | ASSUMED — locks once first user library file lands |
| M4 | Build `/build-rubric-template` skill with 4-phase interview (Purpose → Anchors → Failure modes → Review) | CLEAR |
| M5 | Modify `critique.md` to read attack surface from active template; replace generic critic invocation | CLEAR |
| M6 | Document skill-creator's role in README + CLAUDE.md (resolves orphan flag from `/framework-doctor`) | CLEAR |
| M7 | Auto-detection must keep routine `/score` invocations silent (zero questions when template matches) | CLEAR |
| M8 | When no template matches, present three options: (1) build template via `/build-rubric-template`, (2) one-off rubric for this file only (not saved), (3) skip | CLEAR |
| M9 | New rubric files created via `/build-rubric-template` save to `templates/rubrics/general/` | CLEAR |
| M10 | Backward compatibility: existing `/score` invocations continue to work; behavior change is transparent for users | CLEAR |

### SHOULD (strong preference)

| # | Requirement | Clarity |
|---|-------------|---------|
| S1 | Extend `/framework-doctor` to audit `templates/rubrics/` for orphans (rubrics no extension routes to) and missing critique guidance | CLEAR |
| S2 | Rubric file format supports multiple file-extension matches per template (e.g., `.py` and `.ipynb` both route to a Python rubric) | CLEAR |
| S3 | Auto-detection handles path-based hints when extension is ambiguous (e.g., `.md` in `papers/` vs `docs/` may route differently) | ASSUMED — exact heuristics depend on user libraries |
| S4 | `/score` and `/critique` log which template was used in the session log | CLEAR |
| S5 | When `/build-rubric-template` finishes, immediately re-run `/score` on the original file using the new template | CLEAR |

### MAY (nice to have, deferred)

| # | Requirement | Clarity |
|---|-------------|---------|
| P1 | Severity flags (`--draft`, `--commit`, `--hostile`) for `/critique` | DEFERRED — single mode for now; reactivate if user finds single mode missing things |
| P2 | Stop-hook prompt to save mid-session rubric refinements | DEFERRED — manual edits + git is sufficient |
| P3 | Use skill-creator package as engine for `/build-rubric-template` | DEFERRED — Anthropic-modeled custom interview is leaner; reactivate if 3+ general templates expose limitations |
| P4 | Third seed library (e.g., for fuzzy artifacts like memos / pitch decks) to validate the abstraction generalizes | DEFERRED — confirm format holds with academic + coding first |

---

## Clarity Status Definitions

- **CLEAR** — well understood, no ambiguity
- **ASSUMED** — proceeding on an assumption; flag if proves wrong
- **BLOCKED** — needs user input before proceeding
- **DEFERRED** — explicit choice not to build now; conditions for reactivation noted

---

## Blockers / Open Questions

| Question | Priority | Who decides |
|----------|----------|-------------|
| User must provide academic + coding rubric library files (or first one) before format can lock | HIGH | User |
| Should `templates/rubrics/general/` directory exist from start (empty) or be created on first `/build-rubric-template` run? | LOW | Implementer (suggest: lazy-create) |
| Single combined PR or separate commits per skill? | LOW | User (suggest: one PR, two commits — `/promote` + `/framework-doctor` already done as commit 1; rubric system as commit 2) |
| What happens to existing `/score` invocations on files that don't match any template before user provides libraries? | MEDIUM | Implementer (suggest: fall back to current generic rubric until at least one template exists) |

---

## Approach

Sequential, dependency-ordered:

1. **Lock format** — user provides first rubric file → format inferred from it → spec updated to lock the format → remaining libraries written in that format.
2. **Build modified `score.md`** — template loading by extension, three-option fallback when no match, log template name to session log.
3. **Build modified `critique.md`** — load attack surface from active template, single mode (severity flags deferred per P1).
4. **Build `/build-rubric-template`** — 4-phase interview, writes to `templates/rubrics/general/`, hands back to `/score`.
5. **Update `/framework-doctor`** — add `templates/rubrics/` audit (S1).
6. **Update README + CLAUDE.md** — inventory new files, document skill-creator's role (M6), document new rubric workflow.
7. **Verify** — run `/score` and `/critique` on real academic file and real code file, end-to-end.
8. **Commit + PR** — bundle as the second commit in the unified-workflow PR.

---

## Rubric File Format (Sketch — Subject to Lock-In)

This is the proposed shape; final form locks when first user library file lands.

```markdown
---
name: literature-review
applies_to:
  - "*.tex"
  - "*.md"
path_hints:
  - "papers/"
  - "lit-review/"
description: For academic literature review sections — synthesis of prior work.
---

## Dimensions

| Dimension | Weight | Calibration |
|-----------|--------|-------------|
| Synthesis quality | 35% | 95: novel framing connecting 5+ subfields; 75: solid coverage with one connection; 50: list-of-papers without synthesis |
| Citation completeness | 25% | ... |
| Argumentative clarity | 20% | ... |
| Positioning of own contribution | 20% | ... |

## Critique attack surface

What a hostile peer reviewer attacks first:
- Missing canonical citations in this subfield
- Strawman characterizations of prior work
- Weak transition between literature and own contribution
- Overclaiming novelty when prior work covered similar ground

## Detection signals (used by auto-routing)

- File extension matches `applies_to`
- Path contains any of `path_hints`
- File contains `\cite` or BibTeX-style references
```

---

## Quality Gate

| File | Target Score | Threshold |
|------|--------------|-----------|
| `.claude/commands/score.md` (modified) | ≥ 85 | 80 |
| `.claude/commands/critique.md` (modified) | ≥ 85 | 80 |
| `.claude/commands/build-rubric-template.md` (new) | ≥ 85 | 80 |
| `templates/rubrics/_format.md` (when locked) | ≥ 85 | 80 |
| README.md (after inventory update) | ≥ 90 | 85 |
| CLAUDE.md (after inventory update) | ≥ 90 | 85 |

Files to score before commit:
- All modified or new `.claude/commands/*.md`
- README.md, CLAUDE.md
- The format spec file once locked

User-provided rubric library files are scored by the user against their own
domain expertise — not blocked by `/score` (since they ARE the rubric).

---

## Migration / Backward Compatibility

**Behavior on commit of this spec:**
- `/score file.py` and `/score paper.tex` continue to work
- If a matching template exists in `templates/rubrics/`: new behavior (silent template load)
- If no matching template exists: fall back to current generic rubric, with a one-line notice "No template matched; using generic rubric. Run `/build-rubric-template` to create one."
- This means partial-state deployment is safe — committing `score.md` modifications without any user libraries yet still leaves the system functional.

**No breaking changes** to the slash-command interfaces. Existing muscle memory (`/score`, `/critique`, `/commit`) continues to work.

---

## Out of Scope

Explicitly NOT in this spec:
- Severity flags for `/critique` (P1, deferred)
- Auto-save loop for mid-session refinements (P2, deferred)
- skill-creator integration as engine (P3, deferred)
- A general/ seed template (P4, deferred)
- Modifications to hooks (no new hooks, no changes to existing hook scripts)
- Modifications to `/promote` or `/framework-doctor` beyond the S1 audit extension
- Changes to MCP configuration
- Changes to `new-task-setup.sh` (templates/ symlink already covers rubric inheritance)

---

## Approval

- [ ] User approved this spec
- Approved by: 
- Approved on: 
- Format-lock dependency: pending user-provided first rubric file

---

## Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-04-26 | Initial draft from session conversation | Claude (Opus 4.7) |
