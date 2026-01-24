#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
base=$(mktemp -d)
base=$(cd "$base" && pwd -P)
trap 'cleanup_repo "$repo"; rm -rf "$base"' EXIT

cd "$repo"

path=$(GIT_WT_BASE="$base" "$WT_BIN" switch feat-1 --from main)
assert_match "$base/feat-1" "$path"
[ -d "$path" ] || fail "worktree dir not created"

base_out=$(GIT_WT_BASE="$base" "$WT_BIN" base)
assert_eq "$base" "$base_out"

override_base=$(mktemp -d)
override_base=$(cd "$override_base" && pwd -P)
trap 'cleanup_repo "$repo"; rm -rf "$base"; rm -rf "$override_base"' EXIT

base_override=$(GIT_WT_BASE="$base" "$WT_BIN" --base-dir "$override_base" base)
assert_eq "$override_base" "$base_override"
