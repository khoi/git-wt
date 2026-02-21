#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat-backslash --from main --path '.wt/with\tchars')

out=$("$WT_BIN" ls --plain)
tab=$'\t'
line=$(printf '%s\n' "$out" | grep "^feat-backslash${tab}")
[ -n "$line" ] || fail "missing feat-backslash in plain list output"

listed_path=${line#*$'\t'}
assert_eq "$path" "$listed_path"

case "$listed_path" in
  *$'\t'*)
    fail "listed path contains decoded tab"
    ;;
esac
