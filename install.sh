#!/bin/sh
set -e

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
SRC="${SCRIPT_DIR}/git-wt"

if [ ! -f "${SRC}" ]; then
  printf '%s\n' "error: git-wt not found next to install.sh" >&2
  exit 1
fi

if [ -n "${PREFIX}" ]; then
  PREFIX_DIR="${PREFIX}"
else
  if [ -w /usr/local ] || [ -w /usr/local/bin ]; then
    PREFIX_DIR="/usr/local"
  else
    PREFIX_DIR="${HOME}/.local"
  fi
fi

BIN_DIR="${PREFIX_DIR}/bin"
mkdir -p "${BIN_DIR}"
cp "${SRC}" "${BIN_DIR}/git-wt"
chmod 755 "${BIN_DIR}/git-wt"
printf '%s\n' "installed to ${BIN_DIR}/git-wt"
