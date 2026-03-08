# My Claude Code Agent


**Last Updated:** 2026-03-08

An AI-assisted agent template using **Python + LaTeX/Beamer**. You describe what you want — research ideation/review/development, data analysis, data search — and Claude plans the approach, runs specialized agents, fixes issues, verifies quality, and presents results. 

---

## Quick Start

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/workflow-agent.git my-project
cd my-project
```

### 2. Start Claude Code and Paste This Prompt

```bash
claude
```

Then paste this starter prompt, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe my project in 2–3 sentences.]** I've set up the Claude Code workflow. Please read the configuration files and adapt them for my project. Enter plan mode and start.

**What this does:** Claude will enters contractor mode — planning (ask for approval), implementing, reviewing, and verifying autonomously. 

---

## How It Works

### Contractor Mode

You describe a task. For complex or ambiguous requests, Claude first creates a requirements specification with MUST/SHOULD/MAY priorities and clarity status (CLEAR/ASSUMED/BLOCKED). You approve the spec, then Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates — all autonomously. You see a summary when the work meets quality standards. Say "just do it" and it auto-commits too.

### Specialized Agents

There are specialized agents, which can be added in `./claude/agents`:

- **proofreader** — grammar/typos
- **slide-auditor** — visual layout (Beamer)
- **python-reviewer** — Python code quality and reproducibility


### Quality Gates

Every file gets a score (0–100). Scores below threshold block the action:
- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

### Context Survival

Plans, specifications, and session logs survive auto-compression and session boundaries. The PreCompact hook saves a context snapshot before Claude's auto-compression triggers. MEMORY.md accumulates learning across sessions.

---

## Stack

| Purpose | Tool |
|---------|------|
| Slides | LaTeX/Beamer (XeLaTeX, 3-pass) |
| Data analysis | Python (matplotlib, statsmodels, scikit-learn, pytorch, jax) |
| Notebooks | Jupyter |
| Code quality | black, ruff, mypy |
| Version control | git + GitHub CLI (`gh`) |

---

## Use Cases

| Task | How This Workflow Helps |
|---------------|----------------------|
| Presentation slides (Beamer) | Full creation, multi-agent review, compilation |
| Research papers | Literature review, manuscript review, simulated peer review |
| Data analysis | End-to-end Python pipelines, publication-ready output |
| Research proposals | Structured drafting with adversarial critique |

---

## What's Included

<details>
<summary><strong>Agents, skills, rules, and hooks</strong> (click to expand)</summary>

### Agents (`.claude/agents/`)

| Agent | What It Does |
|-------|-------------|
| `proofreader` | Grammar, typos, overflow, consistency review |
| `slide-auditor` | Visual layout audit for Beamer (overflow, font consistency, spacing) |
| `python-reviewer` | Python code quality, reproducibility, and logic correctness |

### Skills (`.claude/skills/`)

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX compilation with bibtex |
| `/proofread` | Launch proofreader on a file |
| `/visual-audit` | Launch slide-auditor on a file |
| `/review-python` | Launch Python code reviewer |
| `/slide-review` | Combined multi-agent slide review |
| `/devils-advocate` | Challenge design decisions before committing |
| `/create-slides` | Full presentation slides creation workflow |
| `/data-analysis` | End-to-end Python analysis with publication-ready output |
| `/commit` | Stage, commit, create PR, and merge to main |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/review-paper` | Manuscript review: structure, arguments, referee objections |
| `/learn` | Extract non-obvious discoveries into persistent skills |
| `/context-status` | Show session health and context usage |
| `/deep-audit` | Repository-wide consistency audit |

### Rules (`.claude/rules/`)

**Always-on** (no `paths:` frontmatter — load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: implement → verify → review → fix → score |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |
| `meta-governance` | Template vs. working project distinctions |

**Path-scoped** (load only when working on matching files):

| Rule | Triggers On | What It Enforces |
|------|------------|-----------------|
| `verification-protocol` | `.tex`, `.py`, `.ipynb` | Task completion checklist |
| `single-source-of-truth` | `Figures/`, `.tex`, `.py`, `.ipynb`, `output/` | No content duplication |
| `quality-gates` | `.tex`, `.py`, `.ipynb` | 80/90/95 scoring |
| `python-code-conventions` | `*.py`, `*.ipynb` | Python coding standards |
| `tikz-visual-quality` | `.tex` | TikZ diagram visual standards |
| `replication-protocol` | `*.py`, `*.ipynb` | Replicate original results before extending |
| `pdf-processing` | `related_work/` | Safe large PDF handling |
| `proofreading-protocol` | `.tex`, `quality_reports/` | Propose-first, then apply with approval |
| `knowledge-base-template` | `.tex`, `*.py` | Notation/application registry template |
| `orchestrator-research` | `*.py`, `explorations/` | Simple orchestrator for research |
| `exploration-folder-protocol` | `explorations/` | Structured sandbox for experimental work |
| `exploration-fast-track` | `explorations/` | Lightweight exploration workflow (60/100 threshold) |

### Templates (`templates/`)

| Template | What It Does |
|----------|-------------|
| `session-log.md` | Structured session logging format |
| `quality-report.md` | Merge-time quality report format |
| `exploration-readme.md` | Exploration project README template |
| `archive-readme.md` | Archive documentation template |
| `requirements-spec.md` | MUST/SHOULD/MAY requirements framework with clarity status |
| `constitutional-governance.md` | Template for defining non-negotiable principles vs. preferences |
| `skill-template.md` | Academic skill creation template |

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | LaTeX compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| Python 3.10+ | Data analysis | [python.org](https://www.python.org/) or `brew install python` |
| Jupyter | Notebooks | `pip install jupyter` |
| black / ruff / mypy | Code quality | `pip install black ruff mypy` |
| [gh CLI](https://cli.github.com/) | PR workflow | `brew install gh` (macOS) |

Not all tools are needed — install only what your project uses. Claude Code is the only hard requirement.

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles
2. **Update Beamer environments** in `CLAUDE.md` with your custom theorem/definition boxes
3. **Add field-specific Python pitfalls** to `.claude/rules/python-code-conventions.md`
4. **Customize the workflow quick reference** (`.claude/WORKFLOW_QUICK_REF.md`) with your non-negotiables and preferences
5. **Set up the exploration folder** (`explorations/`) for experimental work

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Writing a Good CLAUDE.md](https://code.claude.com/docs/en/memory) — official guidance on project memory

---

## License

MIT License. See [LICENSE](LICENSE).
