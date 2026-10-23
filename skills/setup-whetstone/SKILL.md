---
name: setup-whetstone
description: One-time setup of whetstone on this machine.
disable-model-invocation: true
argument-hint: "(no arguments)"
---

# Setup whetstone

Prepare this machine for the whetstone skills. Everything goes under the user's `~/.claude`; never write into a project. Safe to re-run: each step checks first and changes only what is missing or different.

Ask all questions in one message after the checks, each with a recommended answer. Then apply what was approved.

## 1. Check

- Run `context` ([workflow.md](../_shared/workflow.md#scripts)) and read its `gh` line. Anything but `ok` comes with the fix to tell the user.
- Installed skills: every folder under the whetstone repo's `skills/` that has a SKILL.md, plus `_shared`, should exist in `~/.claude/skills/`. If any are missing, tell the user to run the repo's `scripts/link.sh` (macOS, Linux) or `scripts/link.ps1` (Windows).
- Duplicates: run `claude plugin list`. If the upstream `mattpocock-skills` plugin is enabled, say its skills overlap with these and offer to disable it (`claude plugin disable mattpocock-skills@claude-plugins-official`).
- Output language: read `~/.claude/CLAUDE.md`. Note whether it says which language to reply in.

## 2. Ask

- Style rules: install or update `~/.claude/rules/whetstone.md` from [rules.md](rules.md). If the installed copy differs, show the difference.
- Deny rules: add the rules below to `permissions.deny` in `~/.claude/settings.json`. List the ones not already present; the user may drop any.
- Language: only if `~/.claude/CLAUDE.md` sets none, ask which language replies should use and offer to add one line saying so.

Deny rules (destructive or hard to undo; the user can still run them by hand):

```
Bash(git push --force *)
Bash(git push -f *)
Bash(git reset --hard *)
Bash(git clean -f *)
Bash(git commit --no-verify *)
Bash(gh repo delete *)
Bash(gh issue delete *)
PowerShell(git push --force *)
PowerShell(git push -f *)
PowerShell(git reset --hard *)
PowerShell(git clean -f *)
PowerShell(git commit --no-verify *)
PowerShell(gh repo delete *)
PowerShell(gh issue delete *)
```

## 3. Apply

- Copy rules.md to `~/.claude/rules/whetstone.md`, creating the folder if needed.
- Edit `~/.claude/settings.json` as JSON: keep every existing key, append only missing deny entries. Create the file if it does not exist.
- Make the other approved changes.

## 4. Report

A short table: item, state before, action taken. Mention that a new session picks up the rules, and that `git pull` in the whetstone repo updates the skills.
