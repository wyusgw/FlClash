#!/usr/bin/env bash
# Copies each FlClash-<version>-<name> file in <dir> to FlClash-<name>, so a link to
# releases/latest/download/FlClash-<name> keeps working from one release to the next.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: tool/release_aliases.sh <dir> <version>" >&2
  exit 2
fi
dir="$1"
version="$2"

shopt -s nullglob
files=("$dir"/FlClash-"$version"-*)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "error: no FlClash-$version-* files in $dir" >&2
  exit 1
fi
for file in "${files[@]}"; do
  base="$(basename "$file")"
  cp "$file" "$dir/FlClash-${base#FlClash-"$version"-}"
done
