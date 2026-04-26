# Rubric File Format

**Status:** DRAFT — locks when first hand-tuned library file lands.

## Purpose

Each rubric file defines how `/score` and `/critique` evaluate one artifact
type. Files live in `templates/rubrics/{academic,coding,general}/` and are
auto-loaded by file extension or path hint.

---

## File shape

```yaml
---
name: <kebab-case-identifier>
applies_to:
  - "<glob-pattern>"      # e.g. "*.tex", "*.py"
path_hints:               # optional — used when extension alone is ambiguous
  - "<substring>"         # e.g. "papers/", "methods/"
description: <one-line summary of what artifact this rubric evaluates>
---
```

---

## Required sections

### `## Dimensions`

A markdown table with five columns:

| Dimension | Weight | Anchor 95 | Anchor 75 | Anchor 50 |
|-----------|--------|-----------|-----------|-----------|
| <name> | XX% | <concrete example> | <concrete example> | <concrete example> |

Constraints:
- **3–7 dimensions per rubric.** Fewer than 3 is too coarse; more than 7 becomes unmaintainable. Most artifact types land at 4–6.
- **Weights must sum to 100%.**
- **Anchors must be concrete.** Either:
  - A named real artifact ("Score 95: AdSeqUser handout, scored 93/100"), or
  - Specific verifiable criteria ("Score 95: section structure mirrors paper, ≥60% pages on methodology, all assumptions use the three-bullet template")
  
  What's NOT acceptable: abstract praise like "excellent synthesis" or "high quality work."
  The test: two reviewers, given the same artifact and the same anchor, should score it within 5 points of each other.

### `## Critique attack surface`

A bulleted list. Each bullet describes one failure mode a hostile reviewer
would attack first. Used by `/critique` to focus the critic agent.

Example:

```markdown
## Critique attack surface

- Missing canonical citations in this subfield
- Strawman characterizations of prior work
- Weak transition between literature review and own contribution
- Overclaiming novelty when prior work covered similar ground
```

---

## Optional sections

### `## Detection signals`

Plain-English notes for the human reader on what files this rubric matches.
Auto-detection itself uses only the frontmatter `applies_to` and `path_hints`.

### `## Notes`

Anything else useful for someone refining the rubric later. Free-form.

---

## How auto-detection works

1. `/score <file>` extracts the file's extension.
2. Searches `templates/rubrics/*/` for any rubric whose `applies_to` matches.
3. If exactly one match → load it. Silent.
4. If multiple match → narrow by `path_hints` (substring match against the file's full path).
5. If still ambiguous → ask user "Apply [A] or [B]?" (one question).
6. If no match → fall back to generic rubric + offer `/build-rubric-template`.

### Conflict resolution

When two rubrics' `applies_to` overlap (e.g. two templates both match `*.tex`):

- Path-based templates win over extension-only.
- More specific paths (`papers/methods/`) win over less specific (`papers/`).
- If still tied → ask user.

---

## What this format does NOT include

Deliberate omissions, per the lean design:

- Severity levels for critique (single mode for now; `--draft` / `--hostile` deferred)
- Per-dimension subdimensions (keep flat — four dimensions max)
- Programmatic test cases (this is a markdown spec, not a test framework)
- Example artifacts inline (live in calibration anchors only — keep files small)

---

## Lifecycle

| Action | Where |
|--------|-------|
| Create new rubric | Hand-write in `academic/` or `coding/`, OR run `/build-rubric-template` (writes to `general/`) |
| Refine existing | Edit the file directly; commit |
| Audit format compliance | `/framework-doctor` Check 5 |
| Use the rubric | Auto-loaded by `/score` and `/critique` |
