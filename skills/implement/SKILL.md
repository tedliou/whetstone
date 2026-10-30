---
name: implement
description: Implements a GitHub ticket or a whole spec, one commit per ticket. Use only with an issue number or after to-tickets, not for ad hoc coding.
argument-hint: "#ticket or #spec"
---

# Implement

Build the tickets of one spec on one branch, one commit per ticket. Branch, commit, and issue rules are in [workflow.md](../_shared/workflow.md); read it once before starting.

Everything needed to resume lives in GitHub and git, so running this again later picks up where it stopped.

Shared scripts: `${CLAUDE_SKILL_DIR}/../_shared/scripts/` (how to run them: [workflow.md](../_shared/workflow.md#scripts)).

## 1. Load state

1. Run `context`. Stop if `gh` is not `ok`.
2. Issue number: the argument, else the spec number in the branch name, else ask.
3. Run `tickets <n>`. Read the spec and the tickets you will work on (`gh issue view <n> --json title,body,comments`).
4. If the spec has a Domain changes section, check the files appear in context's `domain` lines. If they are missing, tell the user which files the spec expects and that they may be in another worktree. Do not recreate them.
5. Find the project's build, test, lint, and type-check commands ([repo facts](../_shared/workflow.md#repo-facts)). Skip checks the project does not have.

## 2. Ask once (skip what is already settled)

Put both questions in one message, each with your recommendation:

- Branch: create `<spec#>-<slug>` from `origin/<default>`, or stay on the current branch. Skip when the current branch already carries this spec number.
- Mode: A or B (below). Skip when only one ticket is left, or when every remaining ticket is chained by blockers (nothing can ever run in parallel); use A.

Create the branch with `git fetch origin` then `git switch -c <name> origin/<default>`; uncommitted files come along. If context listed `domain` files, commit only those first with the commit skill, as `docs(domain): <summary>` with `Refs: #<spec>`.

## 3. Work the frontier

Repeat until `tickets` shows no `ready` or `mine` ticket:

1. Pick from `frontier` (and any `mine` ticket left unfinished). Claim each before starting: `gh issue edit <n> --add-assignee @me`.
2. Implement with the `tdd` skill, staying inside the ticket's Scope and Non-goals. If the ticket needs more, stop and ask the user.
3. Run the full test suite and the other project checks. Fix failures before committing.
4. Commit with the `commit` skill: only this ticket's files, `Refs: #<ticket>`.
5. Checkpoint ticket: once the commit exists, invoke `review` with the end of the previous review (or the branch start) as the fixed point, and the ticket number. Fix must-fix findings in a follow-up commit with the same `Refs`. Pass judgement findings on in the final report.
6. Run `tickets` again; finished tickets unblock others.

### Mode A (default, cheaper)

The main session implements tickets itself, keeping one context across tickets. When two or more ready tickets list disjoint files in Expected areas, hand the others to subagents with `model: "sonnet"`, filling the implementer brief in [briefs.md](briefs.md), and send them in one message. They share this working tree, do not commit, and run only their own ticket's tests. When each returns, check its diff, run the full suite, and commit its files as that ticket. Tickets with overlapping areas wait their turn.

### Mode B (long specs)

The main session only coordinates and keeps its context small. Every ticket goes to a `sonnet` subagent with the implementer brief. Parallel tickets with separate areas share the tree, as in mode A. When parallel tickets overlap, give each its own worktree (`git worktree add ../<repo>-t<n> -b <spec#>-t<n>`); that subagent commits on its branch, and you merge it with the `land` script. On a conflict, resolve it in the worktree, `git -C <path> rebase --continue`, and run `land` again.

### Subagent reports

- `DONE`: verify as above, then commit (shared tree) or `land` (worktree).
- `TICKET SCOPE CHANGE REQUIRED`: ask the user, then re-brief or adjust the ticket.
- `BLOCKED`: fix the cause or ask the user.

## 4. Finish

Report in a short table: ticket, status, commit. Add anything left: tickets blocked or taken by others, judgement findings, open worktrees, uncommitted files.

If every ticket is `done`, ask whether to continue with `pr` (review, push, open the PR). On yes, invoke it; that answer also counts as approval to push.
