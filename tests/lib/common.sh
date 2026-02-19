#!/bin/bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  if [ "$1" != "$2" ]; then
    fail "expected '$1' to equal '$2'"
  fi
}

assert_ne() {
  if [ "$1" = "$2" ]; then
    fail "expected '$1' to not equal '$2'"
  fi
}

assert_match() {
  if ! grep -q -- "$1" <<< "$2"; then
    fail "expected '$2' to match '$1'"
  fi
}

assert_not_match() {
  if grep -q -- "$1" <<< "$2"; then
    fail "expected '$2' to not match '$1'"
  fi
}

run_cmd() {
  local err_file
  err_file=$(mktemp)
  set +e
  RUN_OUT=$("$@" 2> "$err_file")
  RUN_RC=$?
  set -e
  RUN_ERR=$(cat "$err_file")
  rm -f "$err_file"
}

assert_rc() {
  if [ "$RUN_RC" -ne "$1" ]; then
    fail "expected exit code $1, got $RUN_RC"
  fi
}

new_repo() {
  local dir
  dir=$(mktemp -d)
  git -C "$dir" init -b main >/dev/null
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config user.name "test"
  printf 'root\n' > "$dir/README.md"
  git -C "$dir" add README.md
  git -C "$dir" commit -m "init" >/dev/null
  printf '%s\n' "$dir"
}

new_repo_with_submodule() {
  local parent source
  parent=$(new_repo)
  source=$(new_repo)
  git -C "$parent" -c protocol.file.allow=always submodule add "$source" deps/ServiceA >/dev/null
  git -C "$parent" commit -am "add submodule" >/dev/null
  SUBMODULE_PARENT_REPO="$parent"
  SUBMODULE_SOURCE_REPO="$source"
  SUBMODULE_PATH="$parent/deps/ServiceA"
  export SUBMODULE_PARENT_REPO
  export SUBMODULE_SOURCE_REPO
  export SUBMODULE_PATH
  printf '%s\n' "$parent"
}

new_bare_repo_with_worktree() {
  local src bare wt
  src=$(new_repo)
  bare=$(mktemp -d)
  rm -rf "$bare"
  git clone --bare "$src" "$bare" >/dev/null
  git -C "$bare" config user.email "test@example.com"
  git -C "$bare" config user.name "test"
  wt=$(mktemp -d)
  git -C "$bare" worktree add "$wt" main >/dev/null
  BARE_SOURCE_REPO="$src"
  BARE_REPO="$bare"
  BARE_WORKTREE="$wt"
  export BARE_SOURCE_REPO
  export BARE_REPO
  export BARE_WORKTREE
  printf '%s\n' "$bare"
}

setup_repo() {
  REPO=$(new_repo)
  export REPO
  trap "cleanup_repo '$REPO'" EXIT
}

setup_repo_with_submodule() {
  new_repo_with_submodule >/dev/null
  trap "cleanup_repo '$SUBMODULE_PARENT_REPO'; cleanup_repo '$SUBMODULE_SOURCE_REPO'" EXIT
  REPO="$SUBMODULE_PARENT_REPO"
  SUBMODULE_REPO="$SUBMODULE_PATH"
  export REPO
  export SUBMODULE_REPO
}

setup_bare_repo_with_worktree() {
  new_bare_repo_with_worktree >/dev/null
  trap "cleanup_repo '$BARE_WORKTREE'; cleanup_repo '$BARE_REPO'; cleanup_repo '$BARE_SOURCE_REPO'" EXIT
  REPO="$BARE_REPO"
  export REPO
}

cleanup_repo() {
  local dir="$1"
  rm -rf "$dir"
}
