#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
repo_real=$(cd "$repo" && pwd -P)
base=$(mktemp -d)
base=$(cd "$base" && pwd -P)
trap 'cleanup_repo "$repo"; rm -rf "$base"' EXIT

cd "$repo"
path=$("$WT_BIN" --base-dir "$base" switch feat-1 --from main)
assert_match "$base/feat-1" "$path"
[ -d "$path" ] || fail "worktree dir not created"

base_out=$("$WT_BIN" --base-dir "$base" base)
assert_eq "$base" "$base_out"

root_out=$("$WT_BIN" --base-dir "$base" root)
assert_eq "$repo_real" "$root_out"

ls_out=$("$WT_BIN" --base-dir "$base" ls --plain)
assert_match "feat-1" "$ls_out"
assert_match "$base/feat-1" "$ls_out"

cd "$path"
here_out=$("$WT_BIN" --base-dir "$base" here)
assert_eq "feat-1" "$here_out"

cd "$repo"
"$WT_BIN" --base-dir "$base" rm feat-1 >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"
