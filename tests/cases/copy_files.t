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

path=$("$WT_BIN" switch feat-copy --from main --copy-ignored --copy-untracked --copy-modified)

[ -f "$path/.env" ] || fail ".env not copied (copy-ignored)"
[ "$(cat "$path/.env")" = "secret" ] || fail ".env content mismatch"

[ -f "$path/untracked.txt" ] || fail "untracked.txt not copied (copy-untracked)"
[ "$(cat "$path/untracked.txt")" = "untracked" ] || fail "untracked.txt content mismatch"

[ -f "$path/README.md" ] || fail "README.md not copied (copy-modified)"
if printf '%s\n' "$(cat "$path/README.md")" | grep -q "modified"; then
  fail "README.md should not be overwritten without --force"
fi

path_force=$("$WT_BIN" switch feat-copy-force --from main --copy-ignored --copy-untracked --copy-modified --force)
[ -f "$path_force/README.md" ] || fail "README.md not copied with --force"
assert_match "modified" "$(cat "$path_force/README.md")"

path2=$("$WT_BIN" switch feat-nocopy --from main)
[ ! -f "$path2/.env" ] || fail ".env should not be copied without flag"
[ ! -f "$path2/untracked.txt" ] || fail "untracked.txt should not be copied without flag"

path3=$("$WT_BIN" switch feat-copy-all --from main --copy-all)
[ -f "$path3/.env" ] || fail ".env not copied (copy-all)"
[ -f "$path3/untracked.txt" ] || fail "untracked.txt not copied (copy-all)"
[ -f "$path3/README.md" ] || fail "README.md not copied (copy-all)"
