# Academic Rubric Library

User-provided rubrics for academic research artifacts.

## What goes here

Hand-tuned rubric files for academic work — literature reviews, methods
sections, results sections, full papers, research code, presentations,
abstracts, etc.

## Format

See [`../_format.md`](../_format.md) for the rubric file format specification.

## Example file names

- `literature-review.md`
- `methods-section.md`
- `results-section.md`
- `full-paper.md`
- `research-coding.md` (if research code differs from general coding)

## Auto-detection

Files in this directory are auto-loaded by `/score` and `/critique` based on
their frontmatter `applies_to` patterns. No manual registration needed.

## Available rubrics

| File | Artifact type | Dimensions |
|------|---------------|------------|
| `paper-summary.md` | LaTeX paper summaries (PhD seminar style) | 6 (Paper-Logic Alignment, Mathematical Rigor, Honesty & Fidelity, Clarity & Pedagogy, Style Compliance, Empirical Restraint) |

## Status

Initial library populated from the Empirical Modeling project's CLAUDE.md
(Spring 2026 PhD seminar). Additional rubrics (homework solutions, research
proposals, lecture notes) can be added as the user encounters those artifact
types.
