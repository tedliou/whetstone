#!/usr/bin/env bash
# Usage: tickets.sh <issue-number>
# Lists a spec and its tickets with a derived status. Given a ticket, lists
# its parent spec. Output format is documented in skills/_shared/github.md.
# Test hook: WHETSTONE_FIXTURES=<dir> reads <dir>/<n>.json instead of calling
# gh (needs jq).
set -u
here="$(cd "$(dirname "$0")" && pwd)"

n="${1:-}"
n="${n#\#}"
case "$n" in
    ''|*[!0-9]*) printf 'error\tusage: tickets <issue-number>\n'; exit 1 ;;
esac

# shellcheck disable=SC2016
filter='
.data.viewer.login as $me
| def row:
    "row\t\(.number)\t\(.state)\t\(.stateReason // "-")"
    + "\t\(if ((.body // "") | test("<!--\\s*whetstone:checkpoint\\s*-->")) then "checkpoint" else "-" end)"
    + "\t\([.blockedBy.nodes[] | select(.state == "OPEN") | .number | tostring] | if length == 0 then "-" else join(",") end)"
    + "\t\(if (.assignees.nodes | length) == 0 then "none" elif ([.assignees.nodes[].login] | index($me)) != null then "me" else "other" end)"
    + "\t\(if ([.closedByPullRequestsReferences.nodes[] | select(.state == "OPEN")] | length) > 0 then "pr" else "-" end)"
    + "\t\(.title)";
.data.repository.issue as $i
| if ($i.subIssues.nodes | length) > 0 then
    "spec\t\($i.number)\t\($i.state | ascii_downcase)\t\($i.title)", ($i.subIssues.nodes[] | row)
  elif $i.parent != null then
    "parent\t\($i.parent.number)"
  else
    "spec\t-\t-\t-", ($i | row)
  end'

fetch() {
    if [ -n "${WHETSTONE_FIXTURES:-}" ]; then
        # jq.exe on Windows writes CRLF; gh's built-in jq does not.
        jq -r "$filter" "$WHETSTONE_FIXTURES/$1.json" | tr -d '\r'
    else
        gh api graphql -F query=@"$here/tickets.graphql" \
            -F owner='{owner}' -F repo='{repo}' -F n="$1" --jq "$filter"
    fi
}

errf="$(mktemp)"
trap 'rm -f "$errf"' EXIT
load() {
    if ! rows="$(fetch "$1" 2>"$errf")"; then
        printf 'error\tcould not read issue #%s: %s\n' "$1" "$(sed -n '$s/^gh: //p' "$errf")"
        exit 1
    fi
}
load "$n"
case "$rows" in
    parent*) load "$(printf '%s' "$rows" | cut -f 2)" ;;
esac

# Tickets committed on this branch but not merged yet ("Refs #n" trailers).
refs=" "
base="$(git symbolic-ref --short -q refs/remotes/origin/HEAD 2>/dev/null)"
if [ -n "$base" ]; then
    for r in $(git log --format=%B "$base..HEAD" 2>/dev/null | grep -oiE 'refs:? +#[0-9]+' | grep -oE '[0-9]+'); do
        refs="$refs$r "
    done
fi
has_ref() { case "$refs" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

frontier=""
while IFS=$'\t' read -r kind num state reason cp blk asg pr title; do
    if [ "$kind" = "spec" ]; then
        printf 'spec\t%s\t%s\t%s\n' "$num" "$state" "$reason"
        continue
    fi
    open=""
    if [ "$blk" != "-" ]; then
        for b in ${blk//,/ }; do
            has_ref "$b" || open="${open:+$open,}$b"
        done
    fi
    if [ "$state" = "CLOSED" ]; then
        if [ "$reason" = "COMPLETED" ]; then s="closed"; else s="not-planned"; fi
    elif [ "$pr" = "pr" ]; then s="in-review"
    elif has_ref "$num"; then s="done"
    elif [ "$asg" = "me" ]; then s="mine"
    elif [ "$asg" = "other" ]; then s="taken"
    elif [ -n "$open" ]; then s="blocked"
    else
        s="ready"
        frontier="${frontier:+$frontier,}$num"
    fi
    printf 'ticket\t%s\t%s\t%s\t%s\t%s\n' "$num" "$s" "$cp" "${open:--}" "$title"
done <<EOF
$rows
EOF
printf 'frontier\t%s\n' "${frontier:--}"
