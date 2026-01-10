#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

cd "$repo"
path1=$("$WT_BIN" open feat-1 --from main)
path2=$("$WT_BIN" open feat-1)
assert_eq "$path1" "$path2"
