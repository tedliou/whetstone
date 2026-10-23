# whetstone

[正體中文](README.md)

Personal Claude Code skills, GitHub only. Forked from [mattpocock/skills](https://github.com/mattpocock/skills) and rewritten. See [UPSTREAM.en.md](UPSTREAM.en.md) for what came from where.

Design points:

- No config files written into your projects. Scripts detect repo facts; anything they cannot detect is asked once and kept in Claude Code auto memory.
- No labels for issue state. State comes from GitHub sub-issues, blocked-by, assignees, and linked PRs.
- Every skill can run alone in a fresh session, because all state lives in GitHub and git.

## Install

Once per machine:

```bash
gh auth login
git clone git@github.com:tedliou/whetstone.git
```

Link the skills into `~/.claude/skills`. macOS and Linux get symlinks; Windows gets junctions (no admin rights needed):

```bash
bash whetstone/scripts/link.sh
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File whetstone/scripts/link.ps1
```

Then run `/setup-whetstone` in Claude Code to write the output style rules and deny rules for dangerous commands. A `git pull` in the repo updates every skill.

## Main flow

```
/grill -> /to-spec -> /to-tickets -> /implement -> /pr -> you merge on GitHub
```

Each step ends by asking whether to continue; say yes and it does. Any step can also be called on its own.

| Step | Result |
|---|---|
| grill | Requirements questioned until clear; GLOSSARY.md and docs/adr/ updated if needed (not committed yet) |
| to-spec | A spec issue |
| to-tickets | Sub-issues (tickets) with blocked-by links and checkpoints marked |
| implement | Tickets claimed, branch chosen, work done, one commit per ticket |
| pr | Review run, then after asking you, push and open a PR with `Closes #n` lines |

Merging the PR into the default branch closes the spec and every ticket.

## Skills

Claude can also invoke these:

| Skill | Purpose |
|---|---|
| [grill](skills/grill/SKILL.md) | Question a plan or idea until both sides understand it the same way |
| [to-spec](skills/to-spec/SKILL.md) | Turn the discussion into a spec issue |
| [to-tickets](skills/to-tickets/SKILL.md) | Split a spec into independently shippable tickets |
| [implement](skills/implement/SKILL.md) | Implement one ticket or a whole spec |
| [pr](skills/pr/SKILL.md) | Review, then open a PR |
| [review](skills/review/SKILL.md) | Check a range of changes against standards and the spec |
| [commit](skills/commit/SKILL.md) | Stage only this change and write a Conventional Commits message |
| [tdd](skills/tdd/SKILL.md) | Test first, implement, refactor on green |
| [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) | Diagnosis loop for hard bugs and performance regressions |
| [domain-modeling](skills/domain-modeling/SKILL.md) | Sharpen terminology; maintain GLOSSARY.md and ADRs |
| [codebase-design](skills/codebase-design/SKILL.md) | Shared vocabulary for deep modules and seams |
| [writing-for-agents](skills/writing-for-agents/SKILL.md) | Write skills, CLAUDE.md, and other agent-facing docs |

Only you can invoke these:

| Skill | Purpose |
|---|---|
| [improve-codebase-architecture](skills/improve-codebase-architecture/SKILL.md) | Find modules worth deepening and propose changes |
| [handoff](skills/handoff/SKILL.md) | Write a handoff note for the next session |
| [retro](skills/retro/SKILL.md) | Review the session for skill or workflow fixes |
| [setup-whetstone](skills/setup-whetstone/SKILL.md) | One-time setup on a new machine |

## License

MIT. Matt Pocock's original copyright is kept; see [LICENSE](LICENSE).
