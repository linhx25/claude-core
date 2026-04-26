---
name: framework-doctor
description: >
  Audit the claude-core framework itself for drift and decay. Checks orphaned
  files, hook integrity, skill description trigger phrases, MEMORY.md tier
  classification, and rubric library format compliance. Run quarterly or
  before promoting work to main.
---

## Framework Doctor Workflow

Run all four checks. Do not auto-fix. Report findings, then propose fixes one
at a time with user approval.

---

### Check 1 — Orphan detection

For each file under these directories:
- `.claude/commands/`
- `.claude/agents/`
- `.claude/skills/`
- `.claude/hooks/`
- `templates/`

Grep for the basename in `README.md` and `CLAUDE.md`. Flag any file referenced
in **neither**.

Skip auto-generated paths: `.claude/snapshots/`, `quality_reports/session-logs/`,
`*.local.*`.

Also skip `templates/rubrics/*/*.md` — individual rubric files are audited
by Check 5, not by orphan detection (README/CLAUDE.md reference the rubric
*directories*, not each rubric file).

For directories (e.g. `.claude/skills/skill-creator/`): check the top-level
directory name, not every file inside.

---

### Check 2 — Hook integrity

For each `.claude/hooks/*.sh`:

1. **Executable bit**: `test -x <hook>` — fail if not executable.
2. **Bash syntax**: `bash -n <hook>` — fail on parse error.
3. **Settings reference**: confirm `.claude/settings.json` references the hook
   under at least one event matcher (`SessionStart`, `PreCompact`, `PostToolUse`,
   `Stop`, etc.). An unreferenced hook is dead code.
4. **Smoke test (optional)**: if `.claude/hooks/_test_fixtures/<hook>.json`
   exists, pipe it as stdin to the hook and confirm exit 0. Otherwise WARN
   that this hook lacks coverage.

---

### Check 3 — Skill description quality

For each `.claude/commands/*.md`:

1. **Description present**: must have a non-empty `description:` field in
   YAML frontmatter.
2. **Trigger phrase**: must contain at least one imperative verb a user
   would actually type (run, score, commit, check, validate, summarize,
   audit, promote, review, etc.). Vague descriptions never trigger.
3. **Length**: 80–400 chars. Too short signals thin content; too long
   signals confusion about purpose.
4. **No vague hedges**: flag descriptions containing "various", "general",
   "miscellaneous", "things" — these are signals the skill's purpose isn't
   crisp.

---

### Check 5 — Rubric library integrity

For each `templates/rubrics/{academic,coding,general}/*.md` (excluding
`README.md` and `_format.md`):

1. **Frontmatter present** — must have `name`, `applies_to`, `description`.
2. **Format compliance** — must contain `## Dimensions` table and `## Critique attack surface` section. See `templates/rubrics/_format.md` for the contract.
3. **Four dimensions** — the Dimensions table must have exactly four rows.
4. **Weights sum to 100%** — extract weights from the table, sum, flag if not 100.
5. **Concrete anchors** — calibration columns (Anchor 95 / 75 / 50) must contain a named example, not abstract criteria. Flag if any anchor is fewer than 5 words or contains no proper noun / specific reference.
6. **Detection coverage** — each rubric's `applies_to` patterns should not collide with another rubric's *without* a `path_hints` discriminator. Flag colliding pairs.
7. **Orphan rubrics** — a rubric whose `applies_to` patterns match no real files in the repo isn't necessarily wrong (it may be reserved for future work), but flag as INFO so the user knows.

---

### Check 4 — MEMORY.md tier sanity

Read `MEMORY.md`. For each `[LEARN:*]` entry:

1. **Path leakage**: flag entries containing absolute paths starting with
   `/Users/`, `/home/`, or `~/` — these are likely HABITs that belong in
   `personal.md`, not universal patterns.
2. **Missing context**: flag entries without a `Context:` line — they fail
   the actionability test.
3. **Tier mismatch**: flag PATTERN entries that read like stable principles
   (universal, design-level, non-negotiable) — candidates for promotion to
   `CLAUDE.md`.
4. **Duplicate titles**: flag any two entries with the same title appearing
   within 30 days of each other.

---

### Report format

```
FRAMEWORK DOCTOR — [date]

Orphans:        [N files]      [PASS / FAIL]
  - [file] (referenced in neither README nor CLAUDE.md)

Hook integrity: [N/M passed]   [PASS / FAIL]
  - [hook]: [specific issue]

Skill descs:    [N/M passable] [PASS / WARN]
  - [skill]: [specific issue]

Rubric library: [N/M compliant] [PASS / WARN / FAIL]
  - [rubric]: [specific issue]

MEMORY tiers:   [N issues]     [PASS / WARN]
  - [entry title]: [specific issue]

OVERALL: [PASS / WARN / FAIL]
TOP ISSUE: [single most important finding]
```

---

### Gating

- **PASS** — no findings. Nothing to do.
- **WARN** — issues found but framework still functional. Offer to fix the
  top issue.
- **FAIL** — broken hook or critical orphan. Recommend fixing before continuing
  task work.

After reporting, ask: "Address findings now? (yes / pick which / not now)"

If yes: propose one fix at a time, get approval, apply, move to the next.
