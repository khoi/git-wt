#!/bin/bash
set -euo pipefail

source "$ROOT/tests/lib/common.sh"

setup_repo
repo="$REPO"

cd "$repo"

cat > .gitignore <<'GI'
build/
vendor/
cache/
*.log
*.tmp
GI
git add .gitignore
git commit -m "add gitignore" >/dev/null

mkdir -p build/debug build/release build/artifacts/arm64
mkdir -p vendor/libfoo/src vendor/libbar
mkdir -p cache/http cache/dns

echo "debug-main" > build/debug/main.o
echo "debug-util" > build/debug/util.o
echo "release-main" > build/release/main.o
echo "arm64-bin" > build/artifacts/arm64/binary
echo "foo-src" > vendor/libfoo/src/foo.c
echo "foo-h" > vendor/libfoo/src/foo.h
echo "bar-lib" > vendor/libbar/bar.a
echo "http-cache" > cache/http/index.html
echo "dns-cache" > cache/dns/hosts
echo "app.log" > app.log
echo "debug.log" > debug.log
echo "session.tmp" > session.tmp
echo "swap.tmp" > swap.tmp
echo "data.tmp" > data.tmp

src_count=$(find build vendor cache -type f | wc -l | tr -d ' ')
src_count=$((src_count + 5))

path=$("$WT_BIN" switch feat-parallel-many --from main --copy-ignored)

dst_count=0
for f in \
  build/debug/main.o build/debug/util.o \
  build/release/main.o build/artifacts/arm64/binary \
  vendor/libfoo/src/foo.c vendor/libfoo/src/foo.h \
  vendor/libbar/bar.a \
  cache/http/index.html cache/dns/hosts \
  app.log debug.log session.tmp swap.tmp data.tmp; do
  [ -f "$path/$f" ] || fail "$f missing in worktree"
  dst_count=$((dst_count + 1))
done

assert_eq "$src_count" "$dst_count"

assert_eq "debug-main" "$(cat "$path/build/debug/main.o")"
assert_eq "release-main" "$(cat "$path/build/release/main.o")"
assert_eq "arm64-bin" "$(cat "$path/build/artifacts/arm64/binary")"
assert_eq "foo-src" "$(cat "$path/vendor/libfoo/src/foo.c")"
assert_eq "bar-lib" "$(cat "$path/vendor/libbar/bar.a")"
assert_eq "http-cache" "$(cat "$path/cache/http/index.html")"
assert_eq "dns-cache" "$(cat "$path/cache/dns/hosts")"
