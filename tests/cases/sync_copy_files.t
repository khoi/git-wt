#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "secret" > .env
echo "*.env" >> .gitignore
git add .gitignore
git commit -m "add gitignore" >/dev/null

echo "untracked" > untracked.txt
echo "modified" >> README.md

path=$("$WT_BIN" switch feat-sync --from main)

cd "$path"
"$WT_BIN" sync --copy-ignored --copy-untracked --copy-modified

[ -f "$path/.env" ] || fail ".env not copied (copy-ignored)"
[ "$(cat "$path/.env")" = "secret" ] || fail ".env content mismatch"

[ -f "$path/untracked.txt" ] || fail "untracked.txt not copied (copy-untracked)"
[ "$(cat "$path/untracked.txt")" = "untracked" ] || fail "untracked.txt content mismatch"

[ -f "$path/README.md" ] || fail "README.md not copied (copy-modified)"
if printf '%s\n' "$(cat "$path/README.md")" | grep -q "modified"; then
  fail "README.md should not be overwritten without --force"
fi

"$WT_BIN" sync --copy-modified --force
assert_match "modified" "$(cat "$path/README.md")"

if "$WT_BIN" sync; then
  fail "expected missing copy flag"
fi

cd "$repo"
echo "source" > conflict.txt

cd "$path"
echo "dest" > conflict.txt

"$WT_BIN" sync --copy-untracked
[ "$(cat "$path/conflict.txt")" = "dest" ] || fail "conflict.txt should not be overwritten without --force"

"$WT_BIN" sync --copy-untracked --force
[ "$(cat "$path/conflict.txt")" = "source" ] || fail "conflict.txt not overwritten with --force"
