---
name: create-slides
description: Create new Beamer lecture from papers and materials. Guided workflow with notation consistency.
argument-hint: "[Topic name]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
context: fork
---

# Lecture Creation Workflow

Create a beautiful, pedagogically excellent Beamer lecture deck.

**This is a collaborative, iterative process. The instructor drives the vision; Claude is a thinking partner.**

---

## CONSTRAINTS (Non-Negotiable)

1. **Read the knowledge base FIRST** — notation registry, narrative arc, applications database
2. Every new symbol MUST be checked against the notation registry
3. Motivation before formalism — no exceptions
4. Worked example within 2 slides of every definition
5. Max 2 colored boxes per slide
6. Transition slides at major conceptual pivots
7. Thread at least 1 running empirical application throughout
8. All citations verified against the bibliography
9. **Work in batches of 5-10 slides** — share for feedback, don't bulk-dump

---

## WORKFLOW

### Phase 0: Intake & Context
- Read knowledge base and creation guide
- Inventory provided materials (papers, slides, code)
- Read previous slides' structure and ending (if any)

### Phase 1: Paper Analysis (When Papers Provided)
- Split into chunks, extract key ideas
- Capture essential idea and method
- Identify slide-worthy content
- Present summary for approval

### Phase 2: Structure Proposal
- Propose outline (5-Act or 3-Part template)
- List diagrams and figures needed
- **GATE: User approves before Phase 3**

### Phase 3: Draft Slides (Iterative)
- Work in batches of 5-10 slides
- Check presentation logistics, apply creation patterns
- Quality checks during drafting

### Phase 4: Figures & Code
- TikZ diagrams in Beamer source (single source of truth)

### Phase 5: Polish & Compile
- Full 3-pass compilation
- Devil's Advocate: challenge the slide design with 5-7 critical questions, work through each cirtique and tell me what survive
- Run Substance Review (if domain reviewer configured)
- Update knowledge base 

---

## Post-Creation Checklist

```
[ ] Lecture compiles without errors
[ ] No overfull hbox > 10pt
[ ] All citations resolve
[ ] Every definition has motivation + worked example
[ ] Max 2 colored boxes per slide
[ ] 2-3 Socratic questions embedded
[ ] Transition slides between sections
[ ] At least 1 running application threaded throughout
[ ] New notation added to knowledge base
[ ] Session log updated
[ ] Devil's Advocate run
```
