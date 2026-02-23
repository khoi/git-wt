#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
mkdir -p app docs
printf 'tracked\n' > app/keep.txt
printf 'tracked\n' > docs/drop.txt
git add app/keep.txt docs/drop.txt
git commit -m "prepare sparse fixtures" >/dev/null

path=$("$WT_BIN" switch feat-sparse --from main)
git -C "$path" sparse-checkout init --cone >/dev/null
git -C "$path" sparse-checkout set app >/dev/null
[ ! -e "$path/docs/drop.txt" ] || fail "non-sparse path should not exist before archive"

printf 'staged\n' >> "$path/app/keep.txt"
git -C "$path" add app/keep.txt
printf 'unstaged\n' >> "$path/app/keep.txt"

"$WT_BIN" archive feat-sparse >/dev/null
restored=$("$WT_BIN" unarchive feat-sparse)
[ -d "$restored" ] || fail "restored worktree missing"

sparse_enabled=$(git -C "$restored" config --bool --get core.sparseCheckout 2>/dev/null || true)
assert_eq "true" "$sparse_enabled"
run_cmd git -C "$restored" sparse-checkout list
assert_rc 0
assert_match "app" "$RUN_OUT"
[ ! -e "$restored/docs/drop.txt" ] || fail "non-sparse path restored after unarchive"

status=$(git -C "$restored" status --porcelain)
assert_match "MM app/keep.txt" "$status"
assert_not_match "docs/drop.txt" "$status"
