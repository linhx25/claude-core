# MEMORY.md — Accumulated Patterns

Append-only. Claude reads this at session start via `session-start.sh` hook.
Run `/memory-prune` quarterly or when entries exceed ~50.

---

## HOW TO USE THIS FILE

**Three tiers — classify before appending:**

| Tier | Tag | What belongs here | Where |
|------|-----|-------------------|-------|
| **PATTERN** | `[LEARN:workflow]` etc. | Reusable cross-project learnings, corrected mistakes | This file |
| **DOMAIN** | `[LEARN:latex]` `[LEARN:python]` etc. | Tool/language-specific gotchas | This file |
| **HABIT** | — | Personal/machine-specific preferences | `personal.md` (gitignored) |
| **PRINCIPLE** | — | Stable design philosophy, non-negotiables | `CLAUDE.md` directly |

When adding an entry via `/learn`, Claude will ask which tier before appending.

**Format:**
```
## [YYYY-MM-DD] — [brief title]
[LEARN:category] [what was wrong or assumed] → [what is actually correct]
Context: [one sentence on when this matters]
```

---
<!-- PRUNED 2026-03-08: Initial population from old MEMORY.md. Principles moved to CLAUDE.md. Habits moved to personal.md. -->
---

## Workflow Patterns

## [2026-03-08] — Spec before plan reduces rework
[LEARN:workflow] Jumping to planning before clarifying requirements → write a requirements spec (MUST/SHOULD/MAY with clarity status) first for any task >1 hour or touching >3 files, then plan.
Context: Catches ambiguity early; reduces rework 30–50% on complex tasks.

## [2026-03-08] — Spec-then-plan protocol
[LEARN:workflow] Asking clarifying questions verbally → use the formal spec protocol: AskUserQuestion (3–5 questions max) → create `quality_reports/specs/YYYY-MM-DD_description.md` → declare CLEAR/ASSUMED/BLOCKED per requirement → get approval → then draft plan.
Context: The written spec survives compression and session boundaries; verbal clarification doesn't.

## [2026-03-08] — Context survival checklist before compression
[LEARN:workflow] Losing plan state on context compression → before any compact: (1) update MEMORY.md with [LEARN] entries, (2) ensure session log is current, (3) save active plan to disk, (4) document open questions. The pre-compact hook displays this checklist.
Context: Plans/specs/logs must live on disk, not in conversation, to survive compression and session boundaries.

## [2026-03-08] — Template meta-work vs user work
[LEARN:workflow] Creating session logs for template-building work → session logs in `quality_reports/` are for user work (slides, analysis, papers), not meta-work (building the repo infrastructure). Keeps the template clean for users who fork it.
Context: Only applies to work on the claude-core repo itself, not task branches.

---

## Documentation

## [2026-03-08] — Update README and guide together
[LEARN:documentation] Adding a feature and updating only one of README/guide → update both immediately. Documentation drift breaks user trust.
Context: Any new template, command, or agent needs entries in both places in the same commit.

## [2026-03-08] — Template inventory must be complete
[LEARN:documentation] Always document new templates in README's "What's Included" section with purpose description. Template inventory must be complete and accurate.

---

## Design

## [2026-03-08] — Generic means any academic workflow
[LEARN:design] Assuming generic = Python/Jupyter, any domain. Test recommendations across these before adding them to core.
Context: The claude-core repo is used across research/analysis/dev branches with very different stacks.

## [2026-03-08] — Constitutional governance: articles not rules
[LEARN:design] Writing rules as flat "thou shalt" statements → constitutional articles distinguish immutable principles (non-negotiable for quality/reproducibility) from flexible preferences. Keep to 3–7 articles max. Each article includes an amendment process: "overriding for this task (one-time exception)" vs "amending Article X (permanent)".
Context: Amendment process preserves institutional memory across sessions.

## [2026-04-26] — Don't lock format specs before real artifacts exist
[LEARN:design] Writing the format spec first then forcing user-provided rubrics to fit → infer format from the first real artifact, then lock. Initial `_format.md` constraint of "exactly four dimensions" had to relax to "3–7" the moment the user's actual rubric (6 dimensions) landed.
Context: Applies whenever building schemas/templates that consume user-provided content. Premature constraints cause spec churn.

## [2026-04-26] — Calibrate rubrics against a known-good exemplar
[LEARN:design] Building a rubric without checking it against a real high-quality artifact → identify a previously-scored reference (e.g., AdSeqUser.tex scored 93/100) and confirm the new rubric scores it in the expected band. Off-by-5+ points either reveals miscalibration or surfaces real issues the old rubric missed.
Context: Verification step for any new rubric template. Catches both mis-tuned weights and "the rubric is doing its job" gaps that look like bugs.

---

## File Organization

## [2026-03-08] — Specs location
[LEARN:files] Saving specification files in repo root or ad-hoc locations → specs go in `quality_reports/specs/YYYY-MM-DD_description.md`. Session logs in `quality_reports/session-logs/`. Maintains structure.
Context: Pre-compact hook and /start-task look for plans in `quality_reports/plans/CURRENT_PLAN.md`.

---

## Memory System

## [2026-03-08] — Two-tier memory for template vs personal
[LEARN:memory] Committing machine-specific preferences to MEMORY.md → use `personal.md` (gitignored) for anything true about your machine, editor, or personal style that wouldn't apply to a collaborator cloning this repo. MEMORY.md is for universal patterns.
Context: Prevents template pollution when others fork claude-core.

---

## Domain: Skills

## [2026-03-08] — Skill descriptions need trigger phrases
[LEARN:skills] Writing vague skill descriptions → use phrases users actually say: "check citations", "format results", "validate protocol". Claude uses descriptions to know when to load a skill; vague descriptions mean it never fires.
Context: Applies to `.claude/commands/*.md` frontmatter `description:` field.

## [2026-03-08] — Skills need three sections minimum
[LEARN:skills] Writing skills with only instructions → include: Instructions (step-by-step), Examples (concrete scenarios), Troubleshooting (common errors). Users debug independently when troubleshooting is present.
Context: Applies when creating any new command or agent file.
