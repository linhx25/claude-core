---
name: score
description: >
  Score any artifact (file, notebook, slide deck, script, document) against
  the universal quality rubric before committing. Invoke as /score [file] or
  /score [file] --domain [research|analysis|dev]. Blocks commit if score < 80.
---

## Score Workflow

### 1. Identify the target

If a file path was passed: use it.
If not: ask "What should I score?" (one question only).

Detect the domain from file extension if `--domain` not passed:
- `.tex`, `.bib`, `.pdf` → research
- `.py`, `.ipynb`, `.csv`, `.parquet` → analysis
- `.js`, `.ts`, `.go`, `.rs`, `.yaml`, `Dockerfile` → dev
- `.md`, `.txt` → whichever domain is active for this task

---

### 2. Score against the universal rubric

Score each dimension 0–100. Be calibrated — 90+ means genuinely excellent,
not just "it works." 70 means it works but has a clear gap. 50 means it
partially works. Below 50 means it needs significant rework.

| Dimension | Weight | Scoring guidance |
|-----------|--------|-----------------|
| **Correctness** | 40% | Does it do exactly what it claims, with no errors? Run it / compile it / open it first. A file that hasn't been executed scores max 70 here. |
| **Completeness** | 25% | Is anything obviously absent? Missing sections, unhandled edge cases, TODOs left in, placeholder text still present? |
| **Clarity** | 20% | Would a collaborator understand this in 5 minutes without asking you? Applies to variable names, comments, structure, and prose alike. |
| **Reproducibility** | 15% | Could someone else get the same result from this artifact alone? Hardcoded paths, missing seeds, undocumented dependencies, and unexplained magic numbers all reduce this. |

**Composite score** = (Correctness × 0.40) + (Completeness × 0.25) + (Clarity × 0.20) + (Reproducibility × 0.15)

Round to nearest integer.

---

### 3. Apply domain overlay (additional criteria)

Domain overlays add checks on top of the universal rubric. They do not change
the four core dimensions — they inform how to score them.

**Task branches may extend this** — if `.claude/commands/score.md` exists on
the task branch, that version takes precedence over this core version.

---

### 4. Report the score

Use this format:

```
SCORE: [file] — [composite]/100

  Correctness    [score]/100 (×0.40) — [one sentence: what's working / what's not]
  Completeness   [score]/100 (×0.25) — [one sentence]
  Clarity        [score]/100 (×0.20) — [one sentence]
  Reproducibility [score]/100 (×0.15) — [one sentence]

VERDICT: [PASS / WARN / BLOCK]
  PASS  ≥ 80 — ready to commit
  WARN  70–79 — committable with caution; note the gap
  BLOCK < 70 — fix before committing

TOP ISSUE: [the single most important thing to fix, if any]
```

---

### 5. Gate action

- **PASS (≥ 80):** proceed to commit. Log score in session log.
- **WARN (70–79):** ask user "Commit anyway, or fix first?" Do not auto-proceed.
- **BLOCK (< 70):** do not commit. State the top issue. Offer to fix it.

If `/commit` is called without a prior `/score`, run scoring automatically
on all staged files before committing.

---

## Calibration examples

| Situation | Correctness | Notes |
|-----------|-------------|-------|
| Script runs clean, all outputs correct | 90–95 | |
| Script runs but one edge case unhandled | 75–80 | |
| Script has a bug that produces wrong output | 40–55 | |
| File not yet executed (untested) | ≤ 70 | Cap at 70 regardless of other dimensions |
| LaTeX compiles with warnings but no errors | 80–85 | |
| LaTeX fails to compile | 0–30 | |

---

## Extending for your task branch

Create `.claude/commands/score.md` on your task branch with additional
domain criteria. Start with:

```markdown
---
name: score
description: Score artifacts for [your domain]. Extends core scoring rubric.
---

## Domain Extensions for [research/analysis/dev]

[Add your specific checks here]

## Then apply core rubric

See core score command for universal dimensions and gating logic.
```