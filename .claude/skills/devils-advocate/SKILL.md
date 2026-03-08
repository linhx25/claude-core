---
name: devils-advocate
description: Challenge document, code, or design decisions with 5-7 critical questions. Checks ordering, assumptions, logic, and cognitive load. Works on slides, papers, scripts, and notebooks.
argument-hint: "[filename or description]"
allowed-tools: ["Read", "Grep", "Glob"]
---

# Devil's Advocate Review

Critically examine a document, script, or design and challenge its decisions with 5-7 specific questions.

**Philosophy:** "We arrive at the best possible work through active dialogue."

---

## Setup

1. **Read the target file** (the document, script, or notebook being challenged)
2. **Read the knowledge base** in `.claude/rules/` for relevant conventions and standards
3. If applicable, **read adjacent files** for broader context

---

## Challenge Categories

Generate 5-7 challenges from these categories:

### 1. Ordering Challenges
> "Could the reader/user understand this better if we showed X before Y?"

### 2. Prerequisite Challenges
> "Does the audience have the background for this concept/technique at this point?"

### 3. Gap Challenges
> "Should we include an intuitive example or motivation before this formal treatment?"

### 4. Alternative Approach Challenges
> "Here are 2 other ways to structure/implement/present this."

### 5. Consistency Challenges
> "This convention conflicts with earlier usage."

### 6. Complexity Challenges
> "This section introduces too many new concepts at once. Can we split?"

### 7. Standalone Challenges
> "If someone reads only this section, do they have enough context?"

---

## Output Format

```markdown
# Devil's Advocate: [Title]

## Challenges

### Challenge 1: [Category] — [Short title]
**Question:** [The specific critical question]
**Why it matters:** [What could go wrong if ignored]
**Suggested resolution:** [Specific action]
**Location:** [Section/line/slide number]
**Severity:** [High / Medium / Low]

[Repeat for 5-7 challenges]

## Summary Verdict
**Strengths:** [2-3 things done well]
**Critical changes:** [0-2 changes before finalizing]
**Suggested improvements:** [2-3 nice-to-have changes]
```

---

## Principles

- **Be specific:** Reference exact locations (lines, sections, slides)
- **Be constructive:** Every challenge has a suggested resolution
- **Be honest:** If the work is good, say so
- **Prioritize:** Logic errors > structural issues > style suggestions
- **Think like the audience:** Where do they get confused or lost?
