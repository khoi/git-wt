#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"

echo "secret" > .env
echo "*.env" >> .gitignore
git add .gitignore
git commit -m "add gitignore" >/dev/null

echo "untracked" > untracked.txt

echo "modified" >> README.md

path=$("$WT_BIN" switch feat-copy --from main --copyignored --copyuntracked --copymodified)

[ -f "$path/.env" ] || fail ".env not copied (copyignored)"
[ "$(cat "$path/.env")" = "secret" ] || fail ".env content mismatch"

[ -f "$path/untracked.txt" ] || fail "untracked.txt not copied (copyuntracked)"
[ "$(cat "$path/untracked.txt")" = "untracked" ] || fail "untracked.txt content mismatch"

[ -f "$path/README.md" ] || fail "README.md not copied (copymodified)"
assert_match "modified" "$(cat "$path/README.md")"

path2=$("$WT_BIN" switch feat-nocopy --from main)
[ ! -f "$path2/.env" ] || fail ".env should not be copied without flag"
[ ! -f "$path2/untracked.txt" ] || fail "untracked.txt should not be copied without flag"
