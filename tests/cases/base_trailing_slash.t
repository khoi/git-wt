#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
base=$(mktemp -d)
base=$(cd "$base" && pwd -P)
trap 'cleanup_repo "$repo"; rm -rf "$base"' EXIT

cd "$repo"
"$WT_BIN" switch feat-1 --from main --base "$base/" >/dev/null

out_no_slash=$("$WT_BIN" ls --json --base "$base")
out_slash=$("$WT_BIN" ls --json --base "$base/")

assert_match "\"branch\":\"feat-1\"" "$out_no_slash"
assert_eq "$out_no_slash" "$out_slash"
