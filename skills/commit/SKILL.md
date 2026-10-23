---
name: commit
description: Commits only the files a change touched, with a Conventional Commits message and Refs trailer. Use when asked to commit.
argument-hint: "[#issue] [what the change is about]"
---

# Commit

Branch, trailer, and staging rules are in [workflow.md](../_shared/workflow.md#commits). This skill applies them.

## Steps

1. Look at `git status --porcelain` and `git diff` (staged and unstaged). Decide which paths belong to this change. Leave unrelated changes alone and mention them in your report. If nothing belongs to this change, say so and stop.
2. Stage those paths by name: `git add -- <path> ...`. If a file mixes this change with unrelated edits, ask the user before staging it.
3. Write the message to a temp file and commit with `git commit -F <file>`. A file avoids quoting problems in every shell.
4. If a hook fails, read its output, fix the cause, stage again, and make a new commit. Never pass `--no-verify`, and never amend a commit that is already pushed.
5. Report one line: short hash and subject.

## Message

```
type(scope): summary

Why the change was needed, when the diff does not make it obvious.

Refs #123
```

- type: feat, fix, refactor, perf, test, docs, build, ci, chore. Breaking changes add `!` after the type and a `BREAKING CHANGE:` footer.
- scope: the module or area, optional.
- summary: imperative, no trailing period, under 72 characters.
- body: wrap at 72. Skip it for small, obvious changes.
- `Refs #n`: the ticket this change belongs to, from the argument, the current task, or the branch name. Omit it when there is no issue.
- Type, scope, and the trailer stay in English. The summary and body follow the output language in workflow.md.
