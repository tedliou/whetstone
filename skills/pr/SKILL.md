---
name: pr
description: Reviews a spec branch, then pushes it and opens a GitHub PR that closes its issues. Use when asked to open a PR, or after implement.
argument-hint: "[#spec-or-ticket]"
metadata:
  credits: "Summary visuals adapted from Dex Horthy's show-me skill (humanlayer/skills)"
---

# PR

Branch and issue rules are in [workflow.md](../_shared/workflow.md). A spec branch becomes one PR into the default branch, and that PR closes the spec and its tickets when merged.

Shared scripts: `${CLAUDE_SKILL_DIR}/../_shared/scripts/` (how to run them: [workflow.md](../_shared/workflow.md#scripts)).

## Steps

1. Run `context`. Stop if `gh` is not `ok`, or if the current branch is the default branch.
2. Find the spec: the argument, else the spec number in the branch name. Run `tickets <spec>`.
   - Tickets with status `done` get a `Closes #n` line, and so does the spec.
   - If some tickets are not `done`, list them and ask whether to open the PR anyway. Without the spec's `Closes` line, the spec stays open.
3. Uncommitted changes: list them and ask. Do not commit them silently.
4. Review once, with a range for each axis. First check that every commit in `origin/<default>..HEAD` has a `Refs` to this spec or one of its tickets; if not, list the others and ask.
   - Standards: the commits not yet reviewed, from the end of the last checkpoint review (or `origin/<default>` when there was none) to `HEAD`. Code is checked against the standards once, so commits a checkpoint already covered aren't checked again.
   - Spec: the whole spec, `origin/<default>...HEAD`, with the spec and all its tickets, so it checks every user story is covered. Coverage belongs to the whole spec: a later ticket can break a story an earlier one delivered, and a story no ticket took shows only against the whole diff.
   - Fix must-fix findings as new commits with the matching `Refs: #n`, then run the project's test command again.
   - Keep judgement findings for the AI review section.
5. Ask once: push and open the PR? Skip the question if the user already said yes in this conversation, for example by accepting implement's offer.
6. `git push -u origin <branch>`, then `gh pr create --base <default> --head <branch> --title <title> --body-file -` with the body on stdin. The title is the spec title.
7. Report the PR URL. The next step is the user's: merge on GitHub.

## Body

Translate headings to the output language. No preamble; keep each section short.

```markdown
## Summary
<one to three sentences on what changed and why, then at most one visual>

## Related issues
Closes #<spec>
Closes #<ticket>

## Verification
- [x] <command actually run>: <result>
<before and after evidence when behaviour is visible>

## AI review
<judgement findings left for a human, one per line, or "None">

## Merge risk
Reversible: <yes, or no and why>. Affects: <who or what could break>.
```

Only list checks that were actually run. Use GLOSSARY.md terms. Append any attribution lines the user or harness requires.

## Summary visual

Pick the smallest view that makes the point, under 15 lines:

| Point to make | Visual |
|---|---|
| Logic or algorithm | pseudocode in a `text` block |
| Runtime flow | call tree |
| UI structure | component tree with the state that matters |
| File responsibilities | shallow file tree with one comment per entry |
| Interaction between parts | Mermaid sequence or flowchart |
| What changed in an existing shape | `diff` block of any of the above |

Skip the visual when one sentence already says it.
