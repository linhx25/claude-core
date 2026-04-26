---
name: paper-summary
applies_to:
  - "*.tex"
path_hints:
  - "Week"              # Week1/, Week2/, ... Week12/
  - "RFM+CLV/"
  - "e-customization/"
  - "AdSeqUser/"
  - "summary"
description: For LaTeX paper summaries in academic seminars — methodology-heavy critical analyses of research papers, structured paper-logic-first.
---

## Dimensions

| Dimension | Weight | Anchor 95 | Anchor 75 | Anchor 50 |
|-----------|--------|-----------|-----------|-----------|
| **Paper-Logic Alignment** | 25% | Section structure mirrors the paper's own (e.g., AdSeqUser handout follows paper §4 Framework as ≥60% of pages, §5–6 strategy/eval at 25–35%, empirical at <10%). No paper-native section is missing. | Mostly mirrors paper but uses a generic-template fallback for one section, OR empirical analysis bloats to 15–20% of pages. | Generic-template structure throughout (Intro / Model / Results / Discussion regardless of paper); paper's actual core methodology section gets <40% of pages. |
| **Mathematical Rigor** | 25% | Every numbered assumption uses the three-bullet template (Why-needed / What-fails / Why-it-holds). Key results in `\boxed{}`. Step-by-step derivations with all intermediate algebra. No forward references. Notation table includes every symbol (including hats). | Most assumptions templated; one or two have only the formal statement. One derivation skips an algebraic step. Notation table is mostly complete. | Multiple assumptions stated without justification template. Derivations skip steps or just state results. Forward references present. Hats used before defined. |
| **Honesty & Fidelity** | 20% | Every numerical value (estimates, t-stats, sample sizes) verbatim from paper tables. Every equation matches the paper. Interpretive claims either traceable to paper or explicitly flagged as handout interpretation. Cross-references to appendices verified. | One or two minor numerical mismatches (e.g., a rounded number). One claim that could be either paper or interpretation. | Fabricated terminology. Numbers don't match the paper. Claims attributed to the paper that aren't actually there. |
| **Clarity & Pedagogy** | 15% | Every formula has both derivation and intuitive interpretation. Jargon defined inline on first use (propensity, HHI, KL, Bellman, etc.). Limiting cases discussed (e.g., β=0 collapses dynamic to myopic). Concrete example for abstract concepts (Alice/session walkthrough scale). Readable without the original paper. | Most formulas interpreted; one or two left as bare equations. Most jargon defined; one term used cold. | Formulas dropped without interpretation. Jargon assumed throughout. Reader needs the original paper to follow. |
| **Style Compliance** | 10% | Zero `\textbf{}` / `\emph{}` / `\textit{}` for inline emphasis. Yes/No (not check/cross symbols) in comparison tables. Terse paragraph titles. No "(Paper Section X.Y)" or "(paper Eq. N)" suffixes on titles. `booktabs` only (no `\hline`). `align` (not `eqnarray`). | One or two stray `\textbf{}` or `\emph{}`. One title with a paper-section suffix. | Pervasive inline emphasis. Check/cross symbols in tables. Long descriptive paragraph titles. `\hline` or `eqnarray` used. |
| **Empirical Restraint** | 5% | Empirical section ≤10% of pages. Single headline table. 3–4 numbered takeaways. Robustness/heterogeneity results referenced in one paragraph, not dedicated subsections. | Empirical section 10–15% of pages. Two tables. | Empirical section 20%+ of pages. Multiple tables, dedicated subsections for each robustness exercise. |

**Weights sum to 100%.**

---

## Critique attack surface

What a hostile reviewer (or `/critique`) attacks first, derived from common
defects on real handouts:

- **Stray characters after LaTeX commands** — `\begin{equation}x` rendering a floating `x`, `\noindentTakeaways` becoming undefined control sequence
- **Forward references** — using a symbol (especially `\hat{}` versions) before it appears in the notation table
- **Notation inconsistency** — `\vartheta` in one place, `\varnothing` in another; pick one and use it everywhere
- **Numbers that don't match the paper** — sample sizes, t-statistics, estimates rounded or transcribed wrong; verify every numerical claim against the paper's tables
- **Assumption stated without the three-bullet template** — every numbered assumption whose violation has substantive consequences must include Why-needed / What-fails / Why-it-holds
- **Generic-template section structure** — when the handout reorders the paper's logic into a generic Intro/Model/Results/Discussion shell instead of mirroring the paper's own section structure
- **Empirical section bloat** — when the empirical analysis exceeds 10% of pages, taking pedagogy budget away from methodology
- **Unescaped `#` in text mode** — LaTeX treats `#` as a macro parameter; must be `\#`
- **Compile silently succeeds but output is wrong** — open the PDF and visually verify after non-trivial edits

---

## Detection signals

Files this rubric matches:

- LaTeX files (`*.tex`) inside `Week<N>/` folders
- LaTeX files inside named-paper folders (`RFM+CLV/`, `e-customization/`, `AdSeqUser/`, etc.)
- LaTeX files containing `\title{\textbf{Paper Discussion Handout}` or similar handout-style title block
- LaTeX files referencing the paper-discussion section structure (Introduction → Previous methods → Settings/DGP → Framework → Empirical strategy → Evaluation methodology → Empirical analysis → Discussion)

Files this rubric does NOT match:

- Research proposal LaTeX files (different structure, different rubric)
- Homework solution LaTeX files (different rubric)
- Reading notes (`Week<N>/notes.md`) — internal preparation artifacts, not formally evaluated by /score

---

## Notes for refinement

**Page budget for methodology-heavy papers (10–14 pages):**

| Section | Share |
|---|---|
| Introduction | ~8% |
| Previous methods | ~12% |
| Settings / DGP | ~8% |
| Framework (theoretical) | ~20–25% |
| Empirical strategy | ~15–20% |
| Evaluation methodology | ~10–15% |
| Empirical analysis | ~5–8% |
| Discussion / Limitations | ~5–8% |

For Bayesian papers (6–8 pages), the allocation compresses proportionally
but preserves the ≥60% share on model + estimation.

**Source:** This rubric is extracted from the Empirical Modeling project's
CLAUDE.md (Spring 2026, B9615-001 PhD Seminar, Prof. Asim Ansari, Columbia GSB).
The 6-dimension structure and weights are verbatim from that source. Anchors
are derived from the project's three reference exemplars and the "Common
defects to watch for" list.
