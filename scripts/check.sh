#!/usr/bin/env bash
# Repo checks. CI runs this; run it locally before pushing.
# Prints one line per problem and exits 1 if any were found.
set -u
cd "$(dirname "$0")/.."
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=C

fail=0
problem() { printf '%s\n' "$*"; fail=1; }

files=$(git ls-files -- ':!*.png' ':!*.jpg')

# Line endings and BOM.
for f in $files; do
    if grep -q $'\r' "$f"; then problem "crlf	$f"; fi
    if [ "$(head -c 3 "$f" | od -An -tx1 | tr -d ' \n')" = "efbbbf" ]; then problem "bom	$f"; fi
done

# Invisible and bidi control characters anywhere.
for f in $files; do
    if grep -nP '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2064}\x{2066}-\x{2069}\x{FEFF}\x{00AD}]' "$f" >/dev/null 2>&1; then
        problem "invisible-char	$f"
    fi
done

# Scripts are ASCII only.
for f in $(git ls-files -- '*.sh' '*.ps1'); do
    if LC_ALL=C grep -nP '[^\x00-\x7F]' "$f" >/dev/null; then problem "non-ascii	$f"; fi
done

# Skill lists stay in sync.
skills=$(for d in skills/*/; do n=$(basename "$d"); [ -f "skills/$n/SKILL.md" ] && echo "$n"; done)
for n in $skills; do
    grep -q "\"./skills/$n\"" .claude-plugin/plugin.json || problem "not-in-plugin.json	$n"
    for r in README.md README.en.md; do
        grep -q "(skills/$n/SKILL.md)" "$r" || problem "not-in-$r	$n"
    done
done
for n in $(grep -o '"./skills/[^"]*"' .claude-plugin/plugin.json | sed 's#"./skills/##; s#"##'); do
    [ -f "skills/$n/SKILL.md" ] || problem "plugin.json-lists-missing	$n"
done

# Frontmatter and size limits.
desc_total=0
for n in $skills; do
    f="skills/$n/SKILL.md"
    front=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")
    name=$(printf '%s\n' "$front" | sed -n 's/^name: *//p')
    [ "$name" = "$n" ] || problem "name-mismatch	$f	$name"
    desc=$(printf '%s\n' "$front" | sed -n 's/^description: *//p')
    [ -n "$desc" ] || problem "no-description	$f"
    if ! printf '%s\n' "$front" | grep -q '^disable-model-invocation: *true'; then
        desc_total=$((desc_total + ${#desc}))
    fi
    # About 4 characters per token; the body must stay under 5,000 tokens.
    body=$(awk 'NR==1{next} f{print} /^---$/{f=1}' "$f" | wc -c)
    [ "$body" -le 20000 ] || problem "too-long	$f	$body chars"
done
[ "$desc_total" -le 1700 ] || problem "descriptions-too-long	$desc_total chars (limit 1700)"

exit $fail
