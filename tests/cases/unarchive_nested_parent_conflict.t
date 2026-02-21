#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
path=$("$WT_BIN" switch feat/index --from main)
printf 'nested restore\n' > "$path/nested.txt"
"$WT_BIN" archive feat/index >/dev/null
git -C "$repo" branch -D feat/index >/dev/null
git -C "$repo" branch feat main >/dev/null

out_file=$(mktemp)
err_file=$(mktemp)
trap 'rm -f "$out_file" "$err_file"; cleanup_repo "$repo"' EXIT

"$WT_BIN" unarchive feat/index >"$out_file" 2>"$err_file" &
pid=$!
ticks=0
while kill -0 "$pid" 2>/dev/null; do
  ticks=$((ticks + 1))
  if [ "$ticks" -gt 100 ]; then
    kill -9 "$pid" 2>/dev/null || true
    fail "unarchive hung on nested parent conflict"
  fi
  sleep 0.05
done

set +e
wait "$pid"
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  fail "unarchive failed: $(cat "$err_file")"
fi

restored=$(cat "$out_file")
[ -d "$restored" ] || fail "restored worktree missing"
restored_branch=$(git -C "$restored" symbolic-ref --short HEAD)
assert_eq "feat-index-restored" "$restored_branch"
[ -f "$restored/nested.txt" ] || fail "nested archive file missing"
