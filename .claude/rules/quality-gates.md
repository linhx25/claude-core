# Quality Gates

Scoring and gating logic. Used by `/score`, `/commit`, and stage advancement.

## Score Thresholds

| Score | Gate | Action |
|-------|------|--------|
| < 70 | **BLOCK** | Do not commit — fix the top issue first |
| 70–79 | **WARN** | Ask before committing; commitable with explicit caveat |
| 80 | Commit threshold | Good to save |
| 85 | Stage-advance threshold (research domain) | Good enough to advance the project to next stage |
| 90 | PR / advisor-share threshold | Ready for review |
| 95 | Excellence | Aspirational target |

## Universal Rubric (Four Dimensions)

| Dimension | Weight | Scoring guidance |
|-----------|--------|------------------|
| **Correctness** | 40% | Does it do exactly what it claims? Run / compile / open it first. A file not yet executed scores max 70 here. |
| **Completeness** | 25% | Anything obviously absent? Missing sections, unhandled edge cases, TODOs, placeholder text? |
| **Clarity** | 20% | Would a collaborator understand in 5 minutes without asking? Applies to names, structure, prose. |
| **Reproducibility** | 15% | Could someone else get the same result from this artifact alone? Hardcoded paths, missing seeds, undocumented deps all reduce. |

**Composite** = (Correctness × 0.40) + (Completeness × 0.25) + (Clarity × 0.20) + (Reproducibility × 0.15). Round to nearest integer.

## Research Domain Overlay

When `--domain research` is passed (or detected from `.tex`, `.bib`, `.pdf`, proposal-shaped `.md`), add these criteria on top of the universal rubric:

| Criterion | Adjusts | What to check |
|-----------|---------|---------------|
| **Framing rigor** | Clarity | Is the managerial decision named with a decision-maker, a choice, and stakes? |
| **Literature coverage** | Completeness | Are the canonical references for this question cited? Any obvious omissions? |
| **Identification strategy** | Correctness | Is the causal claim defensible? Are confounders addressed? |
| **Falsifiability** | Correctness | Is there a result that, if observed, refutes the contribution? |
| **Risk articulation** | Completeness | Are the strongest competing explanations stated explicitly? |

Research-domain artifacts are held to **≥ 85** for stage advancement, **≥ 90** for advisor-share.

## Score Report Format

```
SCORE: [file] — [composite]/100

  Correctness    [x]/100 (×0.40) — [one-sentence rationale]
  Completeness   [x]/100 (×0.25) — [one-sentence rationale]
  Clarity        [x]/100 (×0.20) — [one-sentence rationale]
  Reproducibility [x]/100 (×0.15) — [one-sentence rationale]

VERDICT: [PASS / WARN / BLOCK]
TOP ISSUE: [the single most important thing to fix, if any]
```

## Calibration Examples

| Situation | Correctness band |
|-----------|------------------|
| Script runs clean, all outputs correct | 90–95 |
| Script runs, one edge case unhandled | 75–80 |
| Script has a bug producing wrong output | 40–55 |
| File not yet executed (untested) | ≤ 70 (cap) |
| LaTeX compiles with warnings only | 80–85 |
| LaTeX fails to compile | 0–30 |
| Proposal cites all canonical refs, falsifiable hypothesis | 85–92 |
| Proposal has vague framing, no decision-maker named | 50–65 |

## Pre-Commit Hook

If `/commit` is invoked without a prior `/score`, scoring runs automatically on all staged files. Default verdict is enforced (BLOCK if any file <70, WARN if 70–79, PASS if all ≥80).
