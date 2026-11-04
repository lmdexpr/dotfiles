# Tests for devshell-env with a stubbed nix.
# Usage: bash test.sh [DIR containing devshell-env.sh]
set -uo pipefail

src=${1:-$(dirname "${BASH_SOURCE[0]}")}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
{ echo 'set -o errexit -o nounset -o pipefail'; cat "$src/devshell-env.sh"; } >"$work/bin/devshell-env"

cat >"$work/bin/nix" <<'EOF2'
echo "$*" >>"$STUB/nix-argv"
[[ -f $STUB/fail ]] && { echo 'error: evaluation failed' >&2; exit 1; }
cat <<'JSON'
{"bashFunctions":{"genericBuild":"echo build"},"variables":{
  "PATH":{"type":"exported","value":"/dev/bin"},
  "QUOTED":{"type":"exported","value":"it's \"q\" $HOME\nline2"},
  "HOME":{"type":"exported","value":"/homeless-shelter"},
  "TMPDIR":{"type":"exported","value":"/build"},
  "shellHook":{"type":"exported","value":"touch \"$STUB/hook-ran\""},
  "notExported":{"type":"var","value":"x"},
  "anArray":{"type":"array","value":["a","b"]}
}}
JSON
EOF2
chmod +x "$work/bin"/*

failed=0
fail() { echo "FAIL: $*"; failed=1; }

new_repo() { # make a git repo with flake.nix in SUBDIR
  STUB=$(mktemp -d "$work/it's a case.XXXX")
  repo="$STUB/repo"
  mkdir -p "$repo/$1" "$repo/deep/er"
  git -C "$repo" init -q
  touch "$repo/$1/flake.nix"
  envfile="$STUB/env"
  echo '# kept' >"$envfile"
}

hook() { # CWD [extra env...]
  printf '{"hook_event_name":"CwdChanged","new_cwd":"%s"}' "$1" |
    env -i PATH="$work/bin:$PATH" STUB="$STUB" HOME="$STUB" CLAUDE_ENV_FILE="$envfile" DEVSHELL_SYSTEM=test-system "${@:2}" \
      bash "$work/bin/devshell-env" 2>"$STUB/stderr"
}

# Writes the devShell's exported variables, found from a subdirectory.
new_repo .
hook "$repo/deep/er" || fail "nonzero exit"
[[ $(cat "$STUB/nix-argv") == *"$repo#devShells.test-system.default" ]] || fail "flake ref: $(cat "$STUB/nix-argv")"
# Every shell the Bash tool may use must read the block the same way.
shells=("$BASH")
for sh in dash zsh; do command -v "$sh" >/dev/null && shells+=("$(command -v "$sh")"); done
for sh in "${shells[@]}"; do
  got=$(env -i PATH=/orig HOME=/home/me "$sh" -c 'cd "$2"; . "$1"; printf "%s|%s|%s|%s|%s" "$PATH" "$QUOTED" "$HOME" "${TMPDIR-unset}" "${notExported-unset}${anArray-unset}${shellHook-unset}"' _ "$envfile" "$repo/deep")
  want="/dev/bin:/orig|it's \"q\" \$HOME"$'\n'"line2|/home/me|unset|unsetunsetunset"
  [[ $got == "$want" ]] || fail "sourced env in $sh: $got"
done
[[ $(head -n1 "$envfile") == '# kept' ]] || fail "existing lines not kept"
[[ ! -e $STUB/hook-ran ]] || fail "shellHook ran"
[[ ! -s $STUB/stderr ]] || fail "stderr: $(cat "$STUB/stderr")"

# PATH stays valid when the shell had none.
got=$(env -i "$BASH" -c 'cd "$2"; unset PATH; . "$1"; printf %s "$PATH"' _ "$envfile" "$repo")
[[ $got == /dev/bin ]] || fail "PATH without base: $got"

# Nothing applies outside the flake, including a sibling sharing its prefix.
mkdir "$repo-sibling"
for sh in "${shells[@]}"; do for outside in "$STUB" "$repo-sibling"; do
  got=$(env -i PATH=/orig "$sh" -c 'cd "$2"; . "$1"; printf %s "$PATH${QUOTED-}"' _ "$envfile" "$outside")
  [[ $got == /orig ]] || fail "applied outside the flake in $outside with $sh: $got"
done; done

# The nearest flake.nix wins.
new_repo .
touch "$repo/deep/flake.nix"
hook "$repo/deep/er"
[[ $(cat "$STUB/nix-argv") == *"$repo/deep#devShells"* ]] || fail "nearest flake: $(cat "$STUB/nix-argv")"

no_change() { # NAME
  [[ $(cat "$envfile") == '# kept' ]] || fail "$1: env file changed"
  [[ ! -s $STUB/stderr ]] || fail "$1: stderr: $(cat "$STUB/stderr")"
}

# A flake above the repository root is not used.
new_repo .
git -C "$repo/deep" init -q
hook "$repo/deep/er" || fail "outside repo: nonzero exit"
[[ ! -e $STUB/nix-argv ]] || fail "outside repo: nix called"
no_change "outside repo"

# Directories outside git are skipped.
new_repo .
rm -rf "$repo/.git"
hook "$repo" || fail "no git: nonzero exit"
[[ ! -e $STUB/nix-argv ]] || fail "no git: nix called"
no_change "no git"

# Evaluation failure leaves the file alone.
new_repo .
touch "$STUB/fail"
hook "$repo" || fail "nix failure: nonzero exit"
no_change "nix failure"

# SessionStart passes only cwd.
new_repo .
printf '{"hook_event_name":"SessionStart","cwd":"%s"}' "$repo" |
  env -i PATH="$work/bin:$PATH" STUB="$STUB" CLAUDE_ENV_FILE="$envfile" DEVSHELL_SYSTEM=test-system bash "$work/bin/devshell-env" ||
  fail "SessionStart: nonzero exit"
grep -q '^export QUOTED=' "$envfile" || fail "SessionStart: not written"

# Without CLAUDE_ENV_FILE nothing runs.
new_repo .
hook "$repo" CLAUDE_ENV_FILE= || fail "no env file: nonzero exit"
[[ ! -e $STUB/nix-argv ]] || fail "no env file: nix called"

# Missing directories are ignored.
new_repo .
hook "$repo/missing" || fail "missing dir: nonzero exit"
no_change "missing dir"

((failed == 0)) && echo "all devshell-env tests passed"
exit "$failed"
