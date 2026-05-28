---
name: generic-coding
applies_to:
  - "*.py"
  - "*.go"
  - "*.ts"
  - "*.tsx"
  - "*.js"
  - "*.jsx"
  - "*.rs"
  - "*.rb"
  - "*.java"
  - "*.cpp"
  - "*.c"
  - "*.h"
description: Generic rubric for source code (modules, scripts, libraries, services). Placeholder — intended as a starting point until language-specific or task-specific coding rubrics are added.
---

## Dimensions

| Dimension | Weight | Anchor 95 | Anchor 75 | Anchor 50 |
|-----------|--------|-----------|-----------|-----------|
| **Correctness** | 40% | Code executes cleanly. All claimed behavior verified by running it. Edge cases (empty input, nulls, boundary values, error paths) handled explicitly. No silent failures. | Code runs but one or two edge cases unhandled, OR one error path swallows exceptions silently. | Code has bugs producing wrong output, OR has not been executed at all (cap at 70 until tested). |
| **Maintainability** | 25% | Identifiers are descriptive without being verbose. Functions do one thing each. Module structure makes the data flow obvious. No commented-out code blocks. Comments only where the *why* is non-obvious. | Mostly readable; one or two functions doing too much, or a few cryptic identifiers. | Single-letter variables in non-trivial scope. Functions spanning hundreds of lines. Dead code blocks. Comments restating the code. |
| **Reliability** | 20% | Tests cover the happy path AND the failure paths the code claims to handle. Tests are deterministic. External dependencies (network, filesystem, time) are mocked or pinned. | Happy-path tests only; failure paths untested. OR one flaky test that occasionally hangs. | No tests, OR tests that depend on environment in ways that make them unreproducible. |
| **Reproducibility** | 15% | Dependencies pinned to specific versions in a lockfile. No hardcoded absolute paths. Random seeds set where stochasticity matters. Side-effects (writes to disk, network calls) gated behind explicit configuration. | Mostly reproducible; one hardcoded path or unpinned dependency. | Hardcoded `/Users/...` or `~/...` paths. Unpinned `latest` versions. Stochastic outputs without seeds. |

**Weights sum to 100%.**

---

## Critique attack surface

What a hostile reviewer (or `/critique`) attacks first:

- **Untested error paths** — `try/except: pass`, broad exception catches, error returns that callers don't check
- **Hidden state** — module-level mutables, singletons, globals that two functions both modify
- **Premature abstraction** — interface layers wrapping a single concrete implementation, "just in case" extension points with no second case in sight
- **Concurrency hazards** — shared state across threads/async tasks without explicit synchronization
- **Resource leaks** — file handles, network connections, subprocesses opened but not closed in all branches
- **Hardcoded environment assumptions** — paths, ports, env-var names baked into source rather than configuration
- **Untested side effects** — code that writes files, sends requests, or mutates external state without integration tests
- **Silent type coercion** — implicit conversions (string→int, float→int) that lose information without raising

---

## Detection signals

Files this rubric matches: any file with a recognized source-code extension
listed in `applies_to`.

Files this rubric does NOT match (intentionally):

- Configuration files (`.yaml`, `.json`, `.toml`) — different evaluation criteria
- Build files (`Dockerfile`, `Makefile`, `*.sh`) — operational, not source code
- Tests themselves — could use a separate rubric if test-quality scoring is ever desired

---

## Notes

This is a **placeholder rubric** populated to give the framework something to
match against `*.py`, `*.go`, etc. while a more refined coding library is
built out.

Replace or extend with more specific rubrics as the user encounters distinct
coding artifact types — e.g.:

- `library-module.md` — for reusable library code (different weight on API ergonomics)
- `cli-tool.md` — for command-line tools (different weight on UX, error messages)
- `service.md` — for long-running services (different weight on observability, resilience)
- `notebook.md` — for Jupyter notebooks (different weight on narrative clarity)
- `research-script.md` — for one-off analysis scripts (lower weight on reusability)

When refining, consider also:

- Whether the four-dimension generic structure still fits, or if a coding-specific dimension (e.g., "API ergonomics" or "test coverage" as a standalone) deserves its own slot
- Whether language-specific anchors are needed (Python idioms differ from Go idioms)
- Whether `Reliability` should subdivide into "test coverage" vs. "robustness" vs. "observability"

Refinement is intentionally deferred until enough real coding artifacts have
been scored against this generic version to know what's missing.
