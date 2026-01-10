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
  if ! printf '%s' "$2" | grep -q -- "$1"; then
    fail "expected '$2' to match '$1'"
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

cleanup_repo() {
  local dir="$1"
  rm -rf "$dir"
}
