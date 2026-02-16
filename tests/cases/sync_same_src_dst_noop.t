#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-sync-noop --from main)

echo "change" >> "$path/README.md"

run_cmd "$WT_BIN" sync feat-sync-noop feat-sync-noop --copy-modified
assert_rc 0

assert_match "change" "$(cat "$path/README.md")"
