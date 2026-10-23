#!/usr/bin/env bash
# Usage: context.sh
# Prints gh, repo, branch, and working tree state. Always exits 0.
# Output format is documented in skills/_shared/github.md.
# Test hook: WHETSTONE_OFFLINE=1 skips every gh call.
set -u

offline="${WHETSTONE_OFFLINE:-}"
gh_ok=""
if [ -n "$offline" ]; then
    printf 'gh\tskipped\n'
elif ! command -v gh >/dev/null 2>&1; then
    printf 'gh\tmissing\tinstall from https://cli.github.com then run: gh auth login\n'
elif ! gh issue create --help 2>/dev/null | grep -q -- '--blocked-by'; then
    printf 'gh\ttoo-old\tupgrade gh; issue --parent and --blocked-by are required\n'
elif ! login="$(gh api user --jq .login 2>/dev/null)"; then
    printf 'gh\tnot-logged-in\trun: gh auth login\n'
else
    printf 'gh\tok\t%s\n' "$login"
    gh_ok=1
fi

if ! top="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    printf 'git\tnot-a-repo\n'
    exit 0
fi
printf 'git\tok\t%s\n' "$top"

url="$(git remote get-url origin 2>/dev/null)"
default="$(git symbolic-ref --short -q refs/remotes/origin/HEAD 2>/dev/null)"
default="${default#origin/}"
if [ -z "$default" ] && [ -n "$gh_ok" ]; then
    default="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null)"
fi
case "$url" in
    '') printf 'repo\tnone\tno origin remote\n' ;;
    *github.com[:/]*)
        slug="${url#*github.com[:/]}"
        slug="${slug%.git}"
        printf 'repo\t%s\t%s\n' "$slug" "${default:--}"
        ;;
    *) printf 'repo\tnot-github\t%s\n' "$url" ;;
esac

branch="$(git branch --show-current)"
spec="-"
case "$branch" in
    [0-9]*-*) spec="${branch%%-*}" ;;
esac
case "$spec" in *[!0-9]*) spec="-" ;; esac
ahead="-"
if [ -n "$default" ] && git rev-parse -q --verify "origin/$default" >/dev/null; then
    ahead="$(git rev-list --count "origin/$default..HEAD")"
fi
printf 'branch\t%s\t%s\t%s\n' "${branch:-detached}" "$spec" "$ahead"

status="$(git status --porcelain -uall)"
if [ -z "$status" ]; then
    printf 'changes\t0\n'
else
    printf 'changes\t%s\n' "$(printf '%s\n' "$status" | wc -l | tr -d ' ')"
    printf '%s\n' "$status" | cut -c 4- | sed 's/.* -> //' | grep -E '^(GLOSSARY\.md|docs/adr/)' | while read -r p; do
        printf 'domain\t%s\n' "$p"
    done
fi

git worktree list --porcelain | awk -v top="$top" '
    /^worktree / { path = substr($0, 10); br = "-" }
    /^branch / { br = substr($0, 8); sub("^refs/heads/", "", br) }
    /^$/ { if (path != "" && path != top) printf "worktree\t%s\t%s\n", path, br; path = "" }
    END { if (path != "" && path != top) printf "worktree\t%s\t%s\n", path, br }
'
exit 0
