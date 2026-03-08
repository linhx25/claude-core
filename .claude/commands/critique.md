---
name: critique
description: >
  Runs the critic subagent on a specified file or artifact.
  Use before committing anything important. Pass a file path or describe
  what to critique.
---

## Critique Workflow

1. **Identify the target**
   - If a file path was passed: use it
   - If not: ask "What should I critique?" (one question)

2. **Spawn the critic subagent**
   - Pass the file content and any relevant context (what the artifact is meant to do)
   - The critic returns: WEAKEST POINT, FIX, and CONFIDENCE SCORE

3. **Present results** to the user

4. **Decide next action**
   - If confidence score < 70: address the weakness before proceeding
   - If confidence score 70–89: user decides whether to fix or accept
   - If confidence score ≥ 90: proceed (weakness noted for future improvement)

5. **Log the critique** — append a one-line summary to the session log
