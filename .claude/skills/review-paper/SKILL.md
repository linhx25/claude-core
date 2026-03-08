---
name: review-paper
description: Ruthless, critical manuscript evaluation focusing on problem validity, baseline comparisons, and empirical rigor.
argument-hint: "[paper filename in related_work/ or path to .tex/.pdf]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Critical Manuscript Review

**Role:** You are a critical, Senior Technical Reviewer. Your goal is not to praise the paper, but to ruthlessly evaluate its contribution and validity. You cut through academic fluff to find the actual substance.

**Task:** Read the provided paper and generate a rigorous report targeting problem validity, methodological necessity, and empirical honesty.

**Input:** `$ARGUMENTS` — path to a paper (.tex, .pdf), or a filename in `related_work/`.

---

## Steps

1. **Locate and read the manuscript.** Check:
   - Direct path from `$ARGUMENTS`
   - `related_work/$ARGUMENTS`
   - Glob for partial matches

2. **Read the full paper** end-to-end. For long PDFs, read in chunks (5 pages at a time). Pay special attention to the baselines chosen and the datasets used.

3. **Evaluate the paper** across the four core dimensions defined below.

4. **Produce the critical review report.** Strictly follow the format constraints.

5. **Save to** `quality_reports/critical_review_[sanitized_name].md`

---

## The Four Evaluation Dimensions

### 1. The Research Question (RQ)
- Distill the core question the authors are trying to answer.
- **Constraint:** This MUST be a single, concise sentence. Absolute zero fluff.

### 2. Motivation & Problem Validity
- **Context:** Do not simply restate the authors' claimed motivation. Question it.
- **Evaluation:**
  - Is this a genuine problem or a manufactured/contrived one?
  - Is the problem truly unsolved, or is it already addressed in other contexts/fields that the authors ignored?
  - Does the paper convince you that this gap is actually worth filling?

### 3. Methodology & The "Naive Baseline" Test
- **Summary:** Concisely describe the essential novelty or change introduced. Strip away standard implementation details and mathematical fluff used to make the paper look complex.
- **Critical Thinking:** Compare this method to the simplest possible approach (the naive baseline).
- **Questions to Answer:**
  - What would happen if we used a basic heuristic or standard practice instead?
  - Does the complexity of their solution justify the marginal gain over that simple approach?

### 4. Findings & Critical Analysis
- Ruthlessly interrogate the experiments.
- **For each major experiment, analyze:**
  - **Aim:** What specific hypothesis or claim is being tested?
  - **Setup:** Briefly, how was it tested? (e.g., specific dataset, metric, baseline used).
  - **Result:** What was the concise outcome?
- **Reliability Check & Critique:**
  - Are the results consistent across all datasets, or strong only on specific ones?
  - Did they "cherry-pick" baselines or metrics to make their numbers look better? (e.g., comparing a highly tuned proposed model against untuned or outdated baselines).
  - Are the claims supported by the data, or is there a disconnect between the experiment and the conclusion?

---

## Output Format

```markdown
# Critical Technical Review: [Paper Title]

**Date:** [YYYY-MM-DD]
**Reviewer:** Senior Technical Reviewer (review-paper skill)
**File:** [path to manuscript]

---

## 1. The Research Question (RQ)

[Single, concise sentence stating the core RQ. No fluff.]

## 2. Motivation & Problem Validity (Critical Analysis)

**Assessment of the Problem:**
[Evaluate if the problem is genuine or manufactured. Analyze if it's already solved elsewhere.]

**Verdict on the Gap:**
[State clearly whether the paper convinces you this gap is worth filling, and why/why not.]

## 3. Methodology & The "Naive Baseline" Test

**The Essential Novelty:**
[Concise description of the actual change/contribution, stripped of standard implementation details.]

**The Naive Baseline Comparison:**
- **The Simple Approach:** [Describe the basic heuristic/standard practice.]
- **Complexity vs. Gain:** [Does the proposed complexity justify the marginal gain over the simple approach? What happens if we just use the simple approach?]

## 4. Findings & Critical Analysis

### Experiment 1: [Name/Focus of Experiment]
- **Aim:** [Hypothesis/claim being tested]
- **Setup:** [Dataset, metric, baselines]
- **Result:** [Concise outcome]
- **Reliability Check & Critique:** [Analyze consistency, potential cherry-picking, and whether the data actually supports the conclusion. Call out any disconnects.]

### Experiment 2: [Name/Focus of Experiment]
[Repeat structure for all major experiments...]

---

## Final Reviewer Verdict

**Overall Recommendation:** [Accept / Reject]
**One-Sentence Justification:** [Why it deserves this rating based *only* on the critical analysis above.]