#!/usr/bin/env bash
# Link every whetstone skill (and skills/_shared) into ~/.claude/skills.
# Re-run after adding, removing, or renaming a skill.
# Output: one line per entry, tab separated: <status> <name> [detail]
set -u

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        echo "error	use scripts/link.ps1 on Windows (Git Bash cannot create junctions)"
        exit 1
        ;;
esac

repo="$(cd "$(dirname "$0")/.." && pwd -P)"
src="$repo/skills"
dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
mkdir -p "$dest"

for dir in "$src"/*/; do
    name="$(basename "$dir")"
    target="$src/$name"
    if [ "$name" != "_shared" ] && [ ! -f "$target/SKILL.md" ]; then
        continue
    fi
    link="$dest/$name"
    if [ -L "$link" ]; then
        current="$(readlink "$link")"
        if [ "$current" = "$target" ]; then
            printf 'ok\t%s\n' "$name"
            continue
        fi
        case "$current" in
            "$src"/*) rm "$link" ;;
            *) printf 'skipped\t%s\tlinked elsewhere: %s\n' "$name" "$current"; continue ;;
        esac
    elif [ -e "$link" ]; then
        printf 'skipped\t%s\ta real directory exists; move it away and re-run\n' "$name"
        continue
    fi
    ln -s "$target" "$link"
    printf 'linked\t%s\n' "$name"
done

# Remove links into this repo whose skill no longer exists.
for link in "$dest"/*; do
    [ -L "$link" ] || continue
    current="$(readlink "$link")"
    case "$current" in
        "$src"/*)
            if [ ! -e "$current" ]; then
                rm "$link"
                printf 'removed\t%s\n' "$(basename "$link")"
            fi
            ;;
    esac
done
