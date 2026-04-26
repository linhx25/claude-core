---
name: score
description: >
  Score any artifact against a task-specific rubric loaded from
  templates/rubrics/. Falls back to a generic rubric if no template matches.
  Auto-runs from /commit. Blocks commit if score < 80.
---

## Score Workflow

### 1. Identify the target

If a file path was passed: use it.
If not: ask "What should I score?" (one question only).

---

### 2. Auto-route to the matching rubric template

Search `templates/rubrics/{academic,coding,general}/*.md` for any rubric whose
frontmatter `applies_to` includes a glob pattern matching the target file's
extension or full path.

| Match count | Action |
|-------------|--------|
| Exactly one | Load it. **Silent.** No questions asked. |
| Multiple | Narrow by `path_hints` (substring match against full file path) |
| Still multiple | Ask user: "Apply [A] or [B]?" (one question) |
| Zero | Present three options (see step 5) |

See `templates/rubrics/_format.md` for the rubric file format and detection
conflict-resolution rules.

---

### 3. Apply the loaded rubric

For each of the four dimensions in the loaded rubric file:

- Score 0–100 against that dimension's calibration anchors (95 / 75 / 50)
- Use the anchors **as the standard** — don't invent your own
- If the artifact hasn't been executed (where executable) cap any
  correctness-equivalent dimension at 70

Composite = sum of (dimension_score × dimension_weight). Round to nearest
integer.

---

### 4. Calibration philosophy

The loaded template's anchors define the standard. Be calibrated:
90+ means genuinely excellent against the named anchor, not just "it works."
Trust the template's anchors over generic intuition.

---

### 5. Fallback when no template matches

Present three options to the user:

1. **Build a new template** via `/build-rubric-template` (~10 min interview, saved permanently)
2. **One-off generic score** for this file only (not saved)
3. **Skip**

If user picks (2) or no template exists yet on the repo, fall back to the
generic rubric below. This preserves backward compatibility.

#### Generic rubric (fallback only)

| Dimension | Weight | Scoring guidance |
|-----------|--------|-----------------|
| **Correctness** | 40% | Does it do what it claims? |
| **Completeness** | 25% | Anything obviously absent? |
| **Clarity** | 20% | Would a collaborator understand this in 5 minutes? |
| **Reproducibility** | 15% | Could someone else get the same result? |

Same untested-cap rule applies (Correctness ≤ 70 if not executed).

---

### 6. Report the score

```
SCORE: [file] — [composite]/100   [TEMPLATE: <name> | GENERIC]

  [dimension 1]    [score]/100 (×[weight]) — [one sentence]
  [dimension 2]    [score]/100 (×[weight]) — [one sentence]
  [dimension 3]    [score]/100 (×[weight]) — [one sentence]
  [dimension 4]    [score]/100 (×[weight]) — [one sentence]

VERDICT: [PASS / WARN / BLOCK]
TOP ISSUE: [the single most important thing to fix, if any]
```

The `[TEMPLATE: ...]` line lets the user verify which rubric was used.

---

### 7. Gate action

| Score | Verdict | Action |
|-------|---------|--------|
| ≥ 80 | PASS | Proceed to commit. Log score + template name in session log. |
| 70–79 | WARN | Ask user "Commit anyway, or fix first?" Do not auto-proceed. |
| < 70 | BLOCK | Do not commit. State the top issue. Offer to fix it. |

If `/commit` is called without a prior `/score`, run scoring automatically
on all staged files before committing.

---

### Calibration examples (generic fallback only)

| Situation | Correctness | Notes |
|-----------|-------------|-------|
| Script runs clean, all outputs correct | 90–95 | |
| Script runs but one edge case unhandled | 75–80 | |
| Script has a bug producing wrong output | 40–55 | |
| File not yet executed (untested) | ≤ 70 | Cap regardless of other dimensions |
| LaTeX compiles with warnings but no errors | 80–85 | |
| LaTeX fails to compile | 0–30 | |

For task-specific calibration, see the `## Dimensions` table in the loaded
rubric template.

---

## Extending the rubric library

When you encounter an artifact type with no matching template:
- Run `/build-rubric-template` to create one
- Or hand-edit existing templates in `templates/rubrics/{academic,coding,general}/`

See `templates/rubrics/_format.md` for the rubric file format spec.
