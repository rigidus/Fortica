#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# wrapper: elf2uf2 from Pico SDK must be in PATH
set -e
if ! command -v elf2uf2 >/dev/null ; then
  echo "elf2uf2 not found. Install pico-sdk tools." >&2; exit 1
fi
elf2uf2 "$1" "$2"
