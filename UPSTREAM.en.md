# Upstream

[正體中文](UPSTREAM.md)

whetstone is a fork of [mattpocock/skills](https://github.com/mattpocock/skills) at commit `5beb35b` (v1.3.1, 2026-10-19), tagged `upstream-base` here. The full git history is kept, but the repo is outside GitHub's fork network and has no upstream remote.

## Where each skill came from

| whetstone | Upstream | Change |
|---|---|---|
| grill | grill-me, grill-with-docs, grilling | Merged into one |
| to-spec | to-spec | Rewritten |
| to-tickets | to-tickets | Rewritten to use sub-issues and blocked-by |
| implement | implement, implement-spec | Merged into one |
| pr | pr | Rewritten |
| review | code-review | Renamed and rewritten |
| commit | none | New |
| tdd | tdd | Rewritten; refactor on green added |
| diagnosing-bugs | diagnosing-bugs | Rewritten |
| domain-modeling | domain-modeling | Rewritten |
| codebase-design | codebase-design | Rewritten |
| writing-for-agents | writing-for-agents | Rewritten |
| improve-codebase-architecture | improve-codebase-architecture | Rewritten |
| handoff | handoff | Rewritten |
| retro | retro | Rewritten |
| setup-whetstone | setup-matt-pocock-skills | Rewritten; no longer writes project files |

## Not carried over

- Skills: ask-matt, wayfinder, teach, to-questionnaire, wizard, triage, prototype, research, wait-what, and everything under misc, in-progress, and deprecated.
- GitLab and local-file issue trackers.
- Triage labels and the `docs/agents/` config files.
- Other agent harness config (`agents/openai.yaml`), the docs site, changesets, and release tooling.

## Following upstream

The repo owner watches mattpocock/skills releases. When a new one lands:

```bash
git fetch https://github.com/mattpocock/skills main
git log --oneline upstream-base..FETCH_HEAD
```

Port anything worth taking by rewriting it, and record it below.

## Upstream changes adopted

(none yet)
