#!/usr/bin/env bash
# Runs the _shared scripts offline against a throwaway git repo and checks
# that the .sh and .ps1 versions print the same thing.
# The bash fixture path needs jq. PowerShell versions run when pwsh or
# powershell is on PATH. Exits 1 on any difference.
# SKIP_BASH=1 compares PowerShell against the expected files only, for
# machines without jq.
set -u
here="$(cd "$(dirname "$0")" && pwd -P)"
scripts="$(cd "$here/../../skills/_shared/scripts" && pwd -P)"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

native() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}
shells=""
command -v pwsh >/dev/null 2>&1 && shells="$shells pwsh"
command -v powershell >/dev/null 2>&1 && shells="$shells powershell"

# check <label> <expected-file> <script> [args...]
check() {
    label="$1"; expected="$2"; name="$3"; shift 3
    if [ -n "${SKIP_BASH:-}" ] && [ -n "$expected" ]; then cp "$expected" "$tmp/out.sh"; else bash "$scripts/$name.sh" "$@" > "$tmp/out.sh" 2>&1; fi
    if [ -n "$expected" ] && ! diff -u "$expected" "$tmp/out.sh"; then
        echo "FAIL $label: bash output differs from $(basename "$expected")"; fail=1
    fi
    for sh in $shells; do
        "$sh" -NoProfile -ExecutionPolicy Bypass -File "$(native "$scripts/$name.ps1")" "$@" 2>&1 | tr -d '\r' > "$tmp/out.ps"
        if ! diff -u "$tmp/out.sh" "$tmp/out.ps"; then
            echo "FAIL $label: $sh output differs from bash"; fail=1
        fi
    done
    echo "ran $label"
}

repo="$tmp/repo"
git init -q -b main "$repo"
cd "$repo" || exit 1
git config user.email t@example.com
git config user.name test
git config commit.gpgsign false
git commit -q --allow-empty -m init
git remote add origin git@github.com:octo/demo.git
git update-ref refs/remotes/origin/main HEAD
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
git checkout -q -b 1-greeting
git commit -q --allow-empty -m "feat: parse flags" -m "Refs #2"
mkdir -p docs/adr
echo x > GLOSSARY.md
echo x > docs/adr/0001-flags.md
echo x > notes.txt
git worktree add -q "$tmp/repo-t4" -b 1-t4

export WHETSTONE_OFFLINE=1
export WHETSTONE_FIXTURES
WHETSTONE_FIXTURES="$(native "$here/fixtures")"

check "context" "" context
check "tickets 1" "$here/expected-tickets-1.txt" tickets 1
check "tickets #3" "$here/expected-tickets-1.txt" tickets '#3'
check "tickets 9" "$here/expected-tickets-9.txt" tickets 9
check "tickets bad arg" "" tickets abc

# land: a ticket worktree with one commit, spec branch moved on meanwhile.
(cd "$tmp/repo-t4" && echo t4 > t4.txt && git add t4.txt && git commit -q -m "feat: t4" -m "Refs #4")
git commit -q --allow-empty -m "feat: other"
bash "$scripts/land.sh" 1-t4 > "$tmp/land.txt"
if ! grep -q '^landed	1-t4	1-greeting' "$tmp/land.txt" || [ -d "$tmp/repo-t4" ] || [ "$(git rev-list --merges --count HEAD)" != 0 ]; then
    echo "FAIL land.sh"; cat "$tmp/land.txt"; fail=1
fi
for sh in $shells; do
    git worktree add -q "$tmp/repo-t5" -b "1-t5-$sh"
    (cd "$tmp/repo-t5" && echo "$sh" > "t5-$sh.txt" && git add "t5-$sh.txt" && git commit -q -m "feat: t5")
    git commit -q --allow-empty -m "feat: more"
    "$sh" -NoProfile -ExecutionPolicy Bypass -File "$(native "$scripts/land.ps1")" "1-t5-$sh" | tr -d '\r' > "$tmp/land.txt"
    if ! grep -q "^landed	1-t5-$sh	1-greeting" "$tmp/land.txt" || [ -d "$tmp/repo-t5" ] || [ "$(git rev-list --merges --count HEAD)" != 0 ]; then
        echo "FAIL land.ps1 under $sh"; cat "$tmp/land.txt"; fail=1
    fi
done
echo "ran land"

exit $fail
