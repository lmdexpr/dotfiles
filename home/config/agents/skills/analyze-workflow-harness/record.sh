#!/usr/bin/env bash
# Record one analysis note read from stdin, or prepare the records for reading.
#   record.sh <name> < note.md
#   record.sh --prepare
# If ~/.local/share/harness-notes-local exists, only write the file there and
# do not touch ~/.local/share/harness-notes.
# Otherwise write into the shared clone ~/.local/share/harness-notes, then
# commit and push. If that clone is missing and HARNESS_NOTES_REPO (a clone
# URL) is set, it is cloned first.
# The shared clone is synced before writing and the push is retried after a
# rebase; a failed rebase is always aborted so the clone is never left
# mid-rebase.
# --prepare prints the directory holding past records (nothing if there is
# none) and refreshes the shared clone on a best-effort basis.
set -euo pipefail

local_dir="$HOME/.local/share/harness-notes-local"
shared_dir="$HOME/.local/share/harness-notes"

ensure_shared_clone() {
  if [[ -d "$shared_dir/.git" || -z "${HARNESS_NOTES_REPO:-}" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$shared_dir")"
  git clone --depth 1 -q "$HARNESS_NOTES_REPO" "$shared_dir"
}

sync_shared() {
  if git -C "$shared_dir" pull --rebase -q >&2; then
    return 0
  fi
  git -C "$shared_dir" rebase --abort >/dev/null 2>&1 || true
  return 1
}

if [[ "${1:-}" == "--prepare" ]]; then
  if [[ -d "$local_dir" ]]; then
    echo "$local_dir"
    exit 0
  fi
  ensure_shared_clone || echo "record.sh: could not clone HARNESS_NOTES_REPO" >&2
  if [[ -d "$shared_dir/.git" ]]; then
    sync_shared \
      || echo "record.sh: could not update $shared_dir; using the existing records" >&2
    echo "$shared_dir"
  fi
  exit 0
fi

name="${1:-}"
if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  echo "usage: record.sh <name> < note.md | record.sh --prepare  (name: [A-Za-z0-9._-])" >&2
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

ensure_shared_clone || echo "record.sh: could not clone HARNESS_NOTES_REPO" >&2
if [[ ! -d "$shared_dir/.git" ]]; then
  echo "record.sh: neither $local_dir nor a git clone at $shared_dir; nothing recorded" >&2
  exit 1
fi

if ! sync_shared; then
  echo "record.sh: could not sync $shared_dir; nothing recorded" >&2
  exit 1
fi

write_note "$shared_dir"
git -C "$shared_dir" add -- "$file"
git -C "$shared_dir" commit -q -m "notes: $name" -- "$file"

attempt=1
until git -C "$shared_dir" push -q >&2; do
  if [[ "$attempt" -ge 3 ]] || ! sync_shared; then
    echo "record.sh: note is committed locally at $shared_dir/$file but not pushed" >&2
    exit 1
  fi
  attempt=$((attempt + 1))
done
