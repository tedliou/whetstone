---
name: review
description: Reviews commits on two axes, repo standards and spec fit, with parallel subagents. Use when asked to review a branch, PR, or commit range.
argument-hint: "[range or PR#] [#spec-or-ticket]"
---

# Review

Two independent reviews of one diff, reported side by side and never merged:

- Standards: does the code follow the repo's documented rules (plus a small smell baseline)?
- Spec: does the code do what the issue asked, no more and no less?

A change can pass one and fail the other, so neither report may hide the other.

Shared scripts: `${CLAUDE_SKILL_DIR}/../_shared/scripts/` (how to run them: [workflow.md](../_shared/workflow.md#scripts)).

## 1. Pin the range

- Run the `context` script ([workflow.md](../_shared/workflow.md#scripts)).
- Range from the argument: a ref (`main`, a SHA, a tag) means `<ref>...HEAD`; `A..B` is used as given; a PR number means `gh pr diff <n>`. Without an argument use `origin/<default>...HEAD`.
- A caller may give the Spec review its own range, such as `origin/<default>...HEAD` when pr checks the whole spec while Standards covers only the commits not yet reviewed. Note `git diff --stat` and `git log --oneline` for both ranges.
- Check the range resolves and the diff is not empty before spawning anything. Note `git diff --stat` and `git log --oneline` for the range.

## 2. Find the spec

In order: the `#n` argument, `Refs: #n` / `Closes #n` in the commit messages, the spec number in the branch name. Collect the issue numbers; for a ticket, also its parent spec. Reviewers read the issues themselves, so you only need the numbers. If nothing is found, ask the user; if they say there is no spec, skip the Spec review and say so.

## 3. Find the standards

Collect every file that says how code should be written: CLAUDE.md files (root and nested), CONTRIBUTING.md, CODING_STANDARDS.md, style docs, and the ADRs in docs/adr/ that touch the changed areas. Skip rules a linter or formatter already enforces.

Group the files by the directories they govern. Spawn one Standards reviewer per group that covers changed files, at most three; files with repo-wide scope go to every group.

## 4. Run the reviewers in parallel

Fill the templates in [briefs.md](briefs.md) and send all Agent calls in one message:

| Reviewer | model | Gets |
|---|---|---|
| Standards (one per group) | `haiku` | range, commit list, its standards files, the smell baseline |
| Spec | `sonnet` | range, commit list, spec and ticket numbers |

Wait for every reviewer before writing anything.

## 5. Report

```
## Standards
- path/to/file.ts:42 must-fix CLAUDE.md "no default exports": default export added. Fix: named export.
- path/to/other.ts:10 judgement Feature Envy: reads five fields of Order. Fix: move to Order.

## Spec
- src/cli.ts:30 must-fix "--name is optional": throws when missing. Fix: default to "world".

Standards: 2 (1 must-fix). Spec: 1 (1 must-fix).
```

- One finding per line: location, `must-fix` or `judgement`, the rule or spec line quoted, the problem, the fix.
- Translate headings to the output language; keep `must-fix` and `judgement` as written.
- Do not rerank or merge across the two axes. "No findings" is a valid result.
- When called directly by the user, end by asking which findings to fix. When called by implement or pr, return the report and let the caller act.
