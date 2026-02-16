#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

echo "build/" > .gitignore
git add .gitignore
git commit -m "ignore build dir" >/dev/null

mkdir -p build/cache
echo "a" > build/cache/a.txt
echo "b" > build/top.txt

path=$("$WT_BIN" switch feat-sync-dir-dry --from main)

cd "$path"
run_cmd "$WT_BIN" sync --copy-ignored --dry-run
assert_rc 0
assert_match "build/" "$RUN_OUT"

if printf '%s\n' "$RUN_OUT" | grep -q "build/cache/a.txt"; then
  fail "expected directory boundary output for ignored directory"
fi
