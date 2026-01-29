#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"
base=$(mktemp -d)
trap 'cleanup_repo "$repo"; rm -rf "$base"' EXIT

cd "$repo"
path=$("$WT_BIN" --base-dir "$base" switch feat-1 --from main)
rm -f "$path/.git"

run_cmd git -C "$path" status --porcelain
assert_rc 128
assert_match "not a git repository" "$RUN_ERR"

run_cmd "$WT_BIN" --base-dir "$base" rm feat-1
assert_ne 0 "$RUN_RC"
assert_match "not a git repository" "$RUN_ERR"
[ -e "$path" ] || fail "worktree path missing"

run_cmd "$WT_BIN" --base-dir "$base" rm -f feat-1
assert_rc 0
assert_eq "" "$RUN_ERR"
[ ! -e "$path" ] || fail "worktree path still exists"
