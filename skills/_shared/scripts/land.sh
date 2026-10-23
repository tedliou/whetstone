#!/usr/bin/env bash
# Usage: land.sh <ticket-branch>
# Run in the main worktree, on the spec branch. Rebases the ticket branch
# (which must be checked out in its own worktree) onto the spec branch,
# fast-forwards the spec branch, then removes the worktree and the branch.
# No merge commits. Exits 1 with an "error" line when it stops.
set -u

ticket="${1:-}"
if [ -z "$ticket" ]; then
    printf 'error\tusage: land <ticket-branch>\n'
    exit 1
fi
spec="$(git branch --show-current)"
if [ -z "$spec" ] || [ "$spec" = "$ticket" ]; then
    printf 'error\trun land from the main worktree with the spec branch checked out\n'
    exit 1
fi

wt="$(git worktree list --porcelain | awk -v want="refs/heads/$ticket" '
    /^worktree / { path = substr($0, 10) }
    $0 == "branch " want { print path; exit }
')"
if [ -z "$wt" ]; then
    printf 'error\tno worktree has branch %s checked out\n' "$ticket"
    exit 1
fi
if [ -n "$(git -C "$wt" status --porcelain)" ]; then
    printf 'error\tuncommitted changes in %s; commit or discard them first\n' "$wt"
    exit 1
fi

if ! git -C "$wt" rebase -q "$spec" >/dev/null 2>&1; then
    git -C "$wt" diff --name-only --diff-filter=U | while read -r f; do
        printf 'conflict\t%s\n' "$f"
    done
    printf 'error\tresolve the conflicts in %s, run: git -C "%s" rebase --continue, then run land again\n' "$wt" "$wt"
    exit 1
fi
if ! git merge -q --ff-only "$ticket" >/dev/null 2>&1; then
    printf 'error\tfast-forward of %s to %s failed; check git status in this worktree\n' "$spec" "$ticket"
    exit 1
fi
if ! git worktree remove "$wt" >/dev/null 2>&1; then
    printf 'error\tlanded, but could not remove worktree %s\n' "$wt"
    exit 1
fi
if ! git branch -q -d "$ticket" >/dev/null 2>&1; then
    printf 'error\tlanded, but could not delete branch %s\n' "$ticket"
    exit 1
fi
printf 'landed\t%s\t%s\t%s\n' "$ticket" "$spec" "$(git rev-parse --short HEAD)"
printf 'removed\t%s\n' "$wt"
