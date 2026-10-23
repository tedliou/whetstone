# GitHub reference

How whetstone skills talk to GitHub. Run everything from inside the repo clone; `gh` infers the repo.

## context

No arguments. Always exits 0. One record per line, tab separated:

| Line | Fields | Notes |
|---|---|---|
| `gh` | `ok <login>`, `missing <fix>`, `too-old <fix>`, `not-logged-in <fix>`, `skipped` | Anything but `ok`: tell the user the fix and stop GitHub work |
| `git` | `ok <toplevel>` or `not-a-repo` | |
| `repo` | `<owner/name> <default-branch>`, `none <why>`, `not-github <url>` | `-` when the default branch is unknown |
| `branch` | `<name> <spec#> <ahead>` | spec# is read from a `<n>-slug` branch name, else `-`; ahead is commits ahead of origin's default branch |
| `changes` | `<count>` | Uncommitted paths, including untracked |
| `domain` | `<path>` | One per uncommitted GLOSSARY.md or docs/adr/ path |
| `worktree` | `<path> <branch>` | One per other worktree |

## tickets <n>

`<n>` is a spec or a ticket; a ticket shows its parent spec. Exits 1 with an `error` line when the issue cannot be read.

```
spec      <n> <open|closed> <title>
ticket    <n> <status> <checkpoint|-> <open blockers|-> <title>
frontier  <comma-separated ticket numbers|->
```

Status is one of: ready, blocked, mine, taken, done, in-review, closed, not-planned (see [workflow.md](workflow.md)). Blockers already done on this branch do not count as open. An issue with no parent and no sub-issues prints `spec - - -` and itself as the only ticket.

## land <ticket-branch>

See [workflow.md](workflow.md#branches). Prints `landed` and `removed` on success. On a rebase conflict it prints one `conflict <file>` line per file and an `error` line with the next command, and exits 1.

## gh commands

Pass multi-line bodies on stdin with `--body-file -`, fed by a bash here-doc or a piped PowerShell here-string. This avoids quoting problems and over-long temp file paths.

| Do | Command |
|---|---|
| Read an issue | `gh issue view <n> --json number,title,body,state,comments` |
| Create a spec | `gh issue create --title <t> --body-file -` |
| Create a ticket | `gh issue create --title <t> --body-file - --parent <spec> [--blocked-by <a>,<b>]` |
| Add a blocker later | `gh issue edit <n> --add-blocked-by <m>` |
| Claim | `gh issue edit <n> --add-assignee @me` |
| Release a claim | `gh issue edit <n> --remove-assignee @me` |
| Comment | `gh issue comment <n> --body-file -` |
| Drop as not planned | `gh issue close <n> --reason "not planned"` |
| Open a PR | `gh pr create --base <default> --head <branch> --title <t> --body-file -` |
| Read a PR | `gh pr view <n> --json title,body,state,baseRefName,headRefName` and `gh pr diff <n>` |

Create tickets in dependency order, blockers first, so `--blocked-by` can name real numbers. Mark a checkpoint ticket by putting `<!-- whetstone:checkpoint -->` on its own line in the body; the `tickets` script reads it.

Issue and PR bodies may use Mermaid diagrams; GitHub renders them.
