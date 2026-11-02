#!/usr/bin/env bash
# Record one analysis note read from stdin.
#   record.sh <name> < note.md
# If ~/.local/share/harness-notes-local exists, only write the file there and
# never touch the shared notes (keeps machine-local notes from leaving the host).
# Otherwise write into the shared clone ~/.local/share/harness-notes, then
# commit and push.
set -euo pipefail

local_dir="$HOME/.local/share/harness-notes-local"
shared_dir="$HOME/.local/share/harness-notes"

name="${1:-}"
if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  echo "usage: record.sh <name> < note.md  (name: [A-Za-z0-9._-])" >&2
  exit 2
fi

note="$(cat)"
if [[ -z "${note//[[:space:]]/}" ]]; then
  echo "record.sh: empty note on stdin" >&2
  exit 2
fi

file="notes/$(date +%F)-$name.md"

write_note() {
  local path="$1/$file"
  if [[ -e "$path" ]]; then
    echo "record.sh: $path already exists" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$note" > "$path"
  echo "$path"
}

if [[ -d "$local_dir" ]]; then
  write_note "$local_dir"
  exit 0
fi

if [[ ! -d "$shared_dir/.git" ]]; then
  echo "record.sh: neither $local_dir nor a git clone at $shared_dir; nothing recorded" >&2
  exit 1
fi

write_note "$shared_dir"
git -C "$shared_dir" add -- "$file"
git -C "$shared_dir" commit -q -m "notes: $name" -- "$file"
git -C "$shared_dir" push -q
