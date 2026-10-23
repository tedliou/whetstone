---
name: retro
description: Reviews a coding session and suggests changes to the agent's environment that would make future sessions go better.
argument-hint: "[session id or description; default: this session]"
disable-model-invocation: true
---

# Retro

Look back at one coding session and suggest changes to the agent's environment (CLAUDE.md, checks, standards, tools, skills) so the next session avoids the same friction. The output is a ranked list of suggestions; change nothing until the user picks.

1. Call the Skill tool with "writing-for-agents"; every suggested wording follows it.
2. Read the session. Default to the current one. For another session, find its transcript under `~/.claude/projects/<project>/`, matching the user's description or id.
3. Look for candidates in the categories below. Each needs evidence: the moment in the session where it would have helped.
4. Present the candidates, most severe first. For each: what happened, the proposed change, and the exact file or command it touches. Ask which ones to apply.

## Categories

| Category | Look for it when | Ask |
|---|---|---|
| Navigation | Finding a file or fact took long | Would a pointer line in CLAUDE.md or a doc have saved the search? Are there hidden dependencies between files? |
| Automated checks | The agent made a mistake a tool could catch, or the repo has no guardrail | Does a lint, type, or test command already exist but is not wired into a hook or CI, or is broken? A repo with no pre-commit hook and no CI check is a finding in itself. |
| Coding standards | The review missed a mistake | Is the violation mechanical (banned API, import shape, file location)? Then build a check: a linter rule, hook, or CI job. Only judgement calls go into `CODING_STANDARDS.md`. |
| CLAUDE.md size | The repo or global CLAUDE.md is long | Which lines belong in the standards file, a check, or a linked doc instead? |
| No-ops | Steering files are long | Which instructions would the agent follow anyway? Delete them. |
| Tool economy | A tool call was slow or returned far more than needed | Could a script, a narrower query, or a different tool do it cheaper? |
| Information access | The agent lacked a key fact | Could it get dev server logs, read-only access to a service, or a script that fetches the fact? |

## Where things belong

- CLAUDE.md and AGENTS.md load into every session, so keep them short: mostly pointers to other files.
- `CODING_STANDARDS.md` is read by the review skill, not during implementation. Review sees only the diff and has spare context, so standards are enforced there.
- Docs are reference files reached through pointers. Extend an existing doc before writing a new one.
- A skill is right for reference the model must find on its own (its description stays in context) or for a command the user types.
