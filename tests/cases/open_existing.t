#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path1=$("$WT_BIN" switch feat-1 --from main)
path2=$("$WT_BIN" switch feat-1)
assert_eq "$path1" "$path2"
