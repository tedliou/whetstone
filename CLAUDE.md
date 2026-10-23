# whetstone

Personal Claude Code skills, forked from mattpocock/skills at tag `upstream-base`. GitHub only. Skills never write config files into the projects they run in.

## Layout

- `skills/<name>/SKILL.md`: one folder per skill, flat. Reference files sit next to `SKILL.md`.
- `skills/_shared/`: rules and scripts used by more than one skill. `workflow.md` is the single source for branch, commit, and issue-closing rules. `github.md` covers `gh` usage. `scripts/` holds `context`, `tickets`, and `land`, each as `.sh` and `.ps1`, plus `tickets.graphql`.
- `scripts/`: repo tooling. `link.sh` / `link.ps1` install the skills into `~/.claude/skills`. `check.sh` runs the same checks as CI.
- `tests/scripts/`: offline tests that run every `_shared` script under bash, pwsh, and Windows PowerShell and compare the output.
- `evals/`: trigger and outcome tests.

## Keeping lists in sync

A skill exists when its folder has a `SKILL.md`. Every such skill must appear in:

- `.claude-plugin/plugin.json` `skills`
- the skill tables in `README.md` and `README.en.md`, linked to its `SKILL.md`

`scripts/check.sh` fails when these drift. Run `claude plugin validate . --strict` after touching a manifest.

## Vocabulary

Use these words and no synonyms, in skills and in output. Chinese output uses the fixed translation in brackets.

| Term | Meaning |
|---|---|
| spec | Parent GitHub issue describing one feature. (spec) |
| ticket | Sub-issue of a spec; one independently shippable slice. (票) |
| frontier | Open tickets with no open blockers and no assignee. (可開工的票) |
| checkpoint | A ticket marked for review as soon as it is done, instead of at PR time. (checkpoint) |
| seam | The interface a test drives; where behaviour is observed. (seam) |

Do not call a ticket a slice, task, or story. Do not call a spec a PRD.

## Writing a skill

Token cost and model confusion are the main enemies. Each rule below exists to cut one or the other.

- `SKILL.md`, reference files, scripts, and this file are English. Never tell the model which language to reply in; output follows the user's CLAUDE.md, else the user's message. Templates say "translate headings to the output language".
- Keep the `SKILL.md` body under 5,000 tokens. After compaction only the first 5,000 tokens of a skill survive, so put the rules that must hold first and examples last.
- One fact lives in one place. Shared rules go in `_shared/workflow.md`; skills link to it one level deep and never restate it.
- `description` is third person, says what the skill does and when to use it, key words first. Main-flow skills (grill, to-spec, to-tickets, implement, pr) must say they trigger only with an issue number or when continuing the previous step. Model-invocable descriptions together stay under 1,700 characters.
- User-only skills set `disable-model-invocation: true` and an `argument-hint`.
- Say what to do and why. No MUST, CRITICAL, or capitals for emphasis.
- Deterministic GitHub or git operations go in a `_shared/scripts` script, not in prose the model turns into commands. `${CLAUDE_SKILL_DIR}` is substituted only in SKILL.md, never in reference files or the shell, so every SKILL.md that runs scripts carries the line ``Shared scripts: `${CLAUDE_SKILL_DIR}/../_shared/scripts/` ``. `_shared/workflow.md` explains how to run them in either shell.
- Multi-line text for git or gh goes on stdin (`git commit -F -`, `--body-file -`), not in temp files: Windows temp paths can exceed git's path limit.
- Do not use `!` command injection in skills. It runs one fixed shell and a failure stops the skill from loading.
- Subagent briefs are fill-in templates in a reference file. A subagent sees only its brief.

## Scripts

- Each script has a `.sh` and a `.ps1` with the same arguments, the same output, and the same exit codes.
- Output is English plain text, one record per line, fields separated by a tab. Errors say how to fix them.
- Scripts exit 0 and print their state (for example `gh	not-logged-in`) unless the doc for that script says otherwise.
- Use `gh --jq`; do not require `jq`.
- `.ps1` must run on Windows PowerShell 5.1: no `&&`, `||`, ternary, or `??`. Start with `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.
- Scripts contain ASCII only, including comments.
- All files are UTF-8 without BOM, LF line endings. Paths use forward slashes.

## Prose style

Applies to skills, READMEs, and everything skills produce (replies, issues, PRs, commits).

- No emoji.
- Plain words and short complete sentences. Shorten by cutting repetition and filler, not by compressing into jargon or abbreviations.
- Prefer a diagram to a long paragraph: plain-text diagrams in the terminal, Mermaid in issues and PRs.
- Lists for parallel items; a table when items have two or more attributes to compare.
- No bold or italic for emphasis. Headings and code formatting are fine.
- Explain a term in one sentence the first time it appears.
- No em-dashes. Rewrite the sentence with a comma, colon, period, or parentheses.

## Following upstream

There is no upstream remote. To review what changed upstream since the fork:

```bash
git fetch https://github.com/mattpocock/skills main
git log --oneline upstream-base..FETCH_HEAD -- skills/engineering/tdd
```

Port ideas by rewriting, then record what was taken in `UPSTREAM.md` and `UPSTREAM.en.md`. Move `upstream-base` only when the whole tree has been reviewed.
