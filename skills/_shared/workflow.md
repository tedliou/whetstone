# Workflow rules

The single source for how whetstone skills use branches, commits, and issues. Skills link here instead of restating these rules.

## Words

- spec: a GitHub issue describing one feature. Its tickets are its sub-issues.
- ticket: a sub-issue of a spec, small enough to finish and verify on its own.
- frontier: open tickets with no open blocker and no assignee. Work comes from here.
- checkpoint: a ticket reviewed as soon as it is done, instead of once at PR time.
- seam: the interface a test drives, where behaviour is observed.

Use these words and no synonyms (not slice, task, story, PRD).

## Scripts

Each skill that uses scripts states their folder, with the path already filled in. Run them with whichever shell tool you have; both versions print the same output. Write the full path out: variables like `${CLAUDE_SKILL_DIR}` are not set in the shell.

```
bash "<scripts>/<name>.sh" <args>
powershell -NoProfile -ExecutionPolicy Bypass -File "<scripts>/<name>.ps1" <args>
```

Output formats and `gh` commands are in [github.md](github.md).

Skip a script run or issue read when this conversation already holds its current result, for example an issue you just created or `context` output from a previous step with no branch change since.

## Repo facts

Get each fact in this order and stop at the first hit:

1. `context` script output (repo, default branch, current branch, open worktrees).
2. The project's CLAUDE.md (for example its Commands section) or your auto memory for this project.
3. Ask the user once, offering your best guess.

After asking, save the answer to auto memory so the next session does not ask. Never write config files into the project.

Facts that usually need step 2 or 3: the commands that build, test, lint, and type-check. Every implementation step runs them before committing. A check the project does not have is skipped, not asked about; ask only when no test command can be found.

## Branches

- A spec gets one branch, `<spec#>-<slug>`, cut from the default branch. All its tickets land there and it becomes one PR.
- A ticket with no spec gets `<ticket#>-<slug>`.
- When a ticket needs its own worktree, use branch `<spec#>-t<ticket#>` at `../<repo>-t<ticket#>`, and land it with the `land` script: it rebases onto the spec branch, fast-forwards, and removes the worktree and branch. Never create merge commits.
- If you stop with worktrees still open, list them in your final report.

## Commits

- Conventional Commits: `type(scope): summary`, imperative, under 72 characters.
- Keep any attribution lines the user or the harness asks for, in commits and PR bodies.
- One commit per ticket, ending with the git trailer `Refs: #<ticket>`. This is how later sessions know a ticket is done but not merged.
- Stage only the files this change touched, by path. Never `git add -A` in a tree with unrelated changes.
- Never skip hooks or signing. If a hook fails, fix the cause.
- GLOSSARY.md and docs/adr/ changes from grilling stay uncommitted until a branch is chosen, then go in first as `docs(domain): <summary>` with `Refs: #<spec>`, containing only those files.

## Issues

| State | How it shows |
|---|---|
| ready | open, no open blocker, no assignee |
| mine / taken | assigned to me / to someone else |
| done | `Refs: #n` commit on this branch, issue still open |
| in-review | linked to an open PR |
| closed / not-planned | closed as completed / as not planned |

- Claim a ticket before working on it: `gh issue edit <n> --add-assignee @me`. A ticket assigned to someone else is theirs; ask before taking it.
- Do not close tickets or specs by hand. The PR body has one `Closes #n` line per ticket and one for the spec; merging into the default branch closes them all.
- Close as not planned only when the user decides to drop the work.
- No labels are needed for any of this.

## Scope

A ticket's Scope and Non-Goals are its limits. If the work needs more, stop. A subagent reports `TICKET SCOPE CHANGE REQUIRED: <reason>` and does nothing further; the main session asks the user.

## Moving between steps

The main flow is grill, to-spec, to-tickets, implement, pr. Each step ends by asking whether to continue with the next one; on yes, invoke it. Every step can also start cold in a new session, because its inputs live in GitHub and git.

GLOSSARY.md and ADR edits made while grilling are uncommitted, so a different session or worktree cannot see them. to-spec lists them in the spec body. If implement cannot find them, it tells the user where they are expected instead of guessing.

## Output

Replies, issue bodies, PR bodies, and commit messages follow the user's language setting (their CLAUDE.md), or the language of their messages when none is set. Translate template headings too. Follow the style rules in `~/.claude/rules/whetstone.md` when present.
