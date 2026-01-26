#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

out=$("$WT_BIN" exec feat-1 -- pwd)
assert_eq "$path" "$out"
