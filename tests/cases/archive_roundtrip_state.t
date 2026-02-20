#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"
printf '*.tmp\n' > .gitignore
git add .gitignore
git commit -m "ignore tmp files" >/dev/null

path=$("$WT_BIN" switch feat-archive --from main)
printf 'staged\n' >> "$path/README.md"
git -C "$path" add README.md
printf 'unstaged\n' >> "$path/README.md"
printf 'staged file\n' > "$path/staged.txt"
git -C "$path" add staged.txt
printf 'untracked file\n' > "$path/untracked.txt"
printf 'ignored file\n' > "$path/ignored.tmp"

"$WT_BIN" archive feat-archive >/dev/null
[ ! -d "$path" ] || fail "worktree path still exists"

if ! git -C "$repo" show-ref --verify --quiet refs/heads/feat-archive; then
  fail "branch missing after archive"
fi
if ! git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/meta; then
  fail "archive metadata ref missing"
fi
if ! git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/index; then
  fail "archive index ref missing"
fi
if ! git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/worktree; then
  fail "archive worktree ref missing"
fi

restored=$("$WT_BIN" unarchive feat-archive)
[ -d "$restored" ] || fail "restored worktree missing"

status=$(git -C "$restored" status --porcelain)
assert_match "MM README.md" "$status"
assert_match "A  staged.txt" "$status"
assert_match "?? untracked.txt" "$status"
assert_not_match "ignored.tmp" "$status"
[ ! -e "$restored/ignored.tmp" ] || fail "ignored file restored"

if git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/meta; then
  fail "archive metadata ref still exists"
fi
if git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/index; then
  fail "archive index ref still exists"
fi
if git -C "$repo" show-ref --verify --quiet refs/wt/archive/feat-archive/worktree; then
  fail "archive worktree ref still exists"
fi
