#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"
origin=$(mktemp -d)
trap 'cleanup_repo "$repo"; rm -rf "$origin"' EXIT

git -C "$origin" init --bare >/dev/null
git -C "$repo" remote add origin "$origin"

cd "$repo"

run_cmd "$WT_BIN" switch
assert_rc 1
assert_match "missing branch" "$RUN_ERR"

run_cmd "$WT_BIN" switch feat-1 --from
assert_rc 1
assert_match "missing value for --from" "$RUN_ERR"

run_cmd "$WT_BIN" switch feat-1 --path
assert_rc 1
assert_match "missing value for --path" "$RUN_ERR"

run_cmd "$WT_BIN" switch feat-1 --nope
assert_rc 1
assert_match "unknown flag" "$RUN_ERR"

path=$("$WT_BIN" switch feat-fetch --from main --fetch)
[ -d "$path" ] || fail "worktree path missing"

path2=$("$WT_BIN" switch feat-path --from main --path .wt/custom)
assert_match "/.wt/custom" "$path2"
[ -d "$path2" ] || fail "worktree path missing"

path3=$("$WT_BIN" sw feat-alias --from main)
[ -d "$path3" ] || fail "worktree path missing"
