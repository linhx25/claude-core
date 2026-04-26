# General Rubric Library

Auto-generated rubrics for non-academic, non-coding artifact types.

## How files arrive here

Files in this directory are produced by `/build-rubric-template` when a user
runs `/score` or `/critique` on an artifact whose extension doesn't match any
rubric in `academic/` or `coding/`.

The user is offered a 4-phase comprehensive interview that produces a new
template, saved to this directory.

## Format

See [`../_format.md`](../_format.md) for the rubric file format specification.

Files here follow the same format as `academic/` and `coding/` — the only
difference is they were built interactively rather than hand-tuned upfront.

## Example file names (illustrative)

- `strategy-memo.md`
- `pitch-deck.md`
- `post-mortem.md`
- `meeting-agenda.md`

## Maintenance

Files here are first-class rubrics — edit them directly when refinement is
needed. `/framework-doctor` audits them the same way it audits hand-tuned
libraries.

## Status

Empty until first `/build-rubric-template` run.
