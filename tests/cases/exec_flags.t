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

run_cmd "$WT_BIN" exec
assert_rc 1
assert_match "missing branch" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-1 --from
assert_rc 1
assert_match "missing value for --from" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-1 --path
assert_rc 1
assert_match "missing value for --path" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-1 --nope
assert_rc 1
assert_match "unknown flag" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-1 echo hi
assert_rc 1
assert_match "missing -- before command" "$RUN_ERR"

run_cmd "$WT_BIN" exec feat-1
assert_rc 1
assert_match "missing command" "$RUN_ERR"

path=$("$WT_BIN" exec feat-fetch --from main --fetch -- pwd)
[ -d "$path" ] || fail "worktree path missing"

path2=$("$WT_BIN" exec feat-path --from main --path .wt/exec -- pwd)
assert_match "/.wt/exec" "$path2"
[ -d "$path2" ] || fail "worktree path missing"
