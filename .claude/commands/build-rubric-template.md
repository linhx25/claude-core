---
name: build-rubric-template
description: >
  Build a new rubric template via comprehensive 4-phase interview. Used when
  /score or /critique encounters a file type with no matching rubric. Produces
  a templates/rubrics/general/<name>.md file that auto-routes future invocations.
---

## Build Rubric Template Workflow

This is a heavyweight, intentional process. Budget ~10–15 minutes per template.
The output is a long-lived asset — the investment amortizes across every
future `/score` and `/critique` on this artifact type.

Modeled on the Anthropic skill-creator interview methodology: every probe
demands a concrete example; every dimension demands a calibration anchor;
every "what is this?" pairs with "what is this NOT?"

---

### Phase 1 — Purpose (with negation)

Ask one question at a time. Wait for each answer before moving on.

1. **What is this artifact for?** Demand a concrete example.
2. **Who reads it?** Expert / skeptic / decision-maker / customer / regulator?
3. **What decision does it drive?** What changes after the reader reads it?
4. **What is this artifact NOT for?** What looks similar but should route to a different template? (Boundary cases — captures the "not this" set.)

Refuse abstract answers. If the user says "to communicate ideas" — push back: *which ideas, to whom, for what action?*

---

### Phase 2 — Calibration anchors

Without concrete anchors, the rubric is meaningless. Refuse abstract answers
and re-ask if the user gives them.

5. **What does excellent (95+) look like?** Name a real artifact you'd score that high.
6. **What does adequate (75) look like?** Name a real artifact at this level.
7. **What does failure (50 or below) look like?** Name an artifact that scored this low.

Three concrete reference points become the calibration anchors for every
dimension in the rubric.

---

### Phase 3 — Failure modes (with severity)

8. **What goes wrong most often?** The routine miss.
9. **What's the worst-case embarrassment?** The catastrophic miss.
10. **What does a hostile reviewer attack first?** Frame the most relevant hostile lens — peer reviewer who wants to reject, customer who wants to complain, auditor who wants to find fault, security reviewer scanning for risk.

These three answers populate the `## Critique attack surface` section of the
rubric file.

---

### Phase 4 — Review and iterate

11. **Propose four dimensions.** Based on phases 1–3, suggest four task-specific dimensions with weights summing to 100%. Show the user. Ask: "Are these the right four? Different weights?"
12. **Propose detection rules.** What file extensions and path hints should auto-route to this template? Confirm with user.
13. **Assemble the file.** Produce the full rubric file matching the format in `templates/rubrics/_format.md`.
14. **Show the assembled draft.** Full file contents, including frontmatter.
15. **Iterate.** Ask: "Anything missing? Anything that doesn't belong?" Refine until user accepts.

---

### Step 5 — Save and route

- Write the file to `templates/rubrics/general/<name>.md`
- The file's frontmatter `applies_to` patterns are now picked up by auto-detection on next invocation
- Hand control back to the original `/score` or `/critique` invocation that triggered this build
- Re-run that command — this time the new template loads silently

---

## Constraints

- **Exactly four dimensions.** Refuse to assemble a rubric with three or five.
- **Weights must sum to 100%.** Show the math; refuse to save if it doesn't.
- **Concrete anchors only.** "Smith et al. 2024" is acceptable; "excellent synthesis" is not.
- **Detection rules must be specific.** A pattern like `*.md` with no path hints is too broad — likely conflicts with other rubrics.

---

## When to use this skill

- ✓ A new artifact type appears that no existing rubric covers
- ✓ A user wants to formalize evaluation criteria they've been applying ad-hoc
- ✗ Refining an existing rubric — edit the file directly instead
- ✗ One-off scoring of an unusual artifact — use `/score`'s option-2 generic fallback
- ✗ Creating new slash-commands or subagents — use `.claude/skills/skill-creator/` instead

---

## Why this is heavyweight on purpose

Each new rubric is a long-lived asset that affects every future `/score` and
`/critique` on this artifact type. A skimpy rubric produces unreliable scores,
which erodes trust in the whole quality-gate mechanism. Spending 15 minutes
once for months of accurate scoring afterward is a deliberate trade.

If you don't want this rigor, pick option 2 in `/score` (one-off generic
rubric, not saved) instead.
