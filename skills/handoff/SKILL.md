---
name: handoff
description: Writes a handoff document so a fresh session can continue the current work.
argument-hint: "[what the next session will do]"
disable-model-invocation: true
---

# Handoff

Write a Markdown document that lets a fresh session continue this conversation's work. If the user passed an argument, it says what the next session will focus on; keep what serves that focus and drop the rest.

1. Run the `context` script (see [workflow.md](../_shared/workflow.md#scripts)) to get the repo, branch, uncommitted changes, and open worktrees.
2. Write the document to the OS temp directory (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) as `handoff-<timestamp>.md`, never inside the repo. Give the user its absolute path.

Contents (translate headings to the output language):

- Goal: what the work is for, and the spec or ticket numbers.
- State: branch, what is done, what is in progress, the next step.
- Uncommitted domain edits: every GLOSSARY.md or `docs/adr/` path the `context` script lists. Another session cannot see these unless it runs in the same working tree, so say where they are.
- Open worktrees, if any.
- Decisions and dead ends from this conversation that are not written down anywhere else.
- Suggested skills: which skills the next session should call, and for what.

Link to issues, PRs, commits, ADRs, and files by number, URL, or path instead of copying their content. Replace secrets and personal data with `<REDACTED>`.
