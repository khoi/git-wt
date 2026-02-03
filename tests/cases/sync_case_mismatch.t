#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

base=$(mktemp -d "/tmp/WtCaseXXXXXX")
trap "cleanup_repo '$base'" EXIT

repo="$base/Repo"
mkdir -p "$repo"
git -C "$repo" init -b main >/dev/null
git -C "$repo" config user.email "test@example.com"
git -C "$repo" config user.name "test"
printf 'root\n' > "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -m "init" >/dev/null

cd "$repo"
path=$("$WT_BIN" switch feat-1 --from main)

printf 'payload\n' > "$repo/untracked.txt"

alt_base="/tmp/wtcase${base#/tmp/WtCase}"
if [ ! -d "$alt_base" ] || ! [ "$alt_base" -ef "$base" ]; then
  exit 0
fi

alt_path="${path/#$base/$alt_base}"
if [ ! -d "$alt_path" ] || ! [ "$alt_path" -ef "$path" ]; then
  exit 0
fi

cd "$alt_path"
run_cmd "$WT_BIN" sync --copy-untracked --dry-run
assert_rc 0
assert_match "untracked.txt" "$RUN_OUT"
