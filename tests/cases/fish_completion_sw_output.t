#!/bin/bash
set -euo pipefail

. "${ROOT}/tests/lib/common.sh"

if ! command -v fish >/dev/null 2>&1; then
  exit 0
fi

repo=$(new_repo)
trap 'cleanup_repo "$repo"' EXIT

repo_real=$(cd "$repo" && pwd -P)
branch="fish-test"
expected="$repo_real/.worktrees/$branch"

out=$(FISH_WT_BIN="$WT_BIN" FISH_REPO="$repo" FISH_BRANCH="$branch" fish -c 'source (command $FISH_WT_BIN completion fish | psub); cd "$FISH_REPO"; wt sw "$FISH_BRANCH"; pwd')

assert_eq "$expected" "$out"
[ -d "$expected" ] || fail "worktree dir not created"

help_out=$(FISH_WT_BIN="$WT_BIN" fish -c 'source (command $FISH_WT_BIN completion fish | psub); wt sw --help')
line_count=$(printf '%s\n' "$help_out" | wc -l | tr -d ' ')
if [ "$line_count" -le 2 ]; then
  fail "help output collapsed"
fi
