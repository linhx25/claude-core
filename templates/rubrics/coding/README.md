# Coding Rubric Library

User-provided rubrics for coding artifacts.

## What goes here

Hand-tuned rubric files for code — library modules, scripts, services,
notebooks, CLI tools, configuration, etc.

## Format

See [`../_format.md`](../_format.md) for the rubric file format specification.

## Example file names

- `library-module.md`
- `cli-tool.md`
- `service.md`
- `notebook.md`
- `config-file.md`

## Auto-detection

Files in this directory are auto-loaded by `/score` and `/critique` based on
their frontmatter `applies_to` patterns. No manual registration needed.

## Available rubrics

| File | Artifact type | Dimensions |
|------|---------------|------------|
| `generic-coding.md` | All source code (placeholder) | 4 (Correctness, Maintainability, Reliability, Reproducibility) |

## Status

Placeholder generic rubric in place. Refinement deferred — see notes inside
`generic-coding.md` for the kinds of specialized rubrics that may eventually
replace or extend it (`library-module.md`, `cli-tool.md`, `service.md`, etc.).
The user is actively soliciting recommendations on what specialization makes
sense for their workflow.
