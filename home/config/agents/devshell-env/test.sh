# Tests for devshell-env with a stubbed nix.
# Usage: bash test.sh [DIR containing devshell-env.sh]
set -uo pipefail

src=${1:-$(dirname "${BASH_SOURCE[0]}")}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/stub"
work=$(cd "$work" && pwd -P)
STUB=$work/stub

{ echo 'set -o errexit -o nounset -o pipefail'; cat "$src/devshell-env.sh"; } >"$work/bin/devshell-env"

# print-dev-env answers with $STUB/<flake dir name>.json, or fails without one.
cat >"$work/bin/nix" <<'EOF'
echo "$*" >>"$STUB/nix-argv"
args=" $* "
case $args in
  *" config show system "*) echo x86_64-linux ;;
  *" print-dev-env "*)
    for a; do [[ $a == *#devShells.* ]] && ref=$a; done
    dir=${ref%%#*}
    [[ -f $STUB/${dir##*/}.json ]] || { echo "error: no devShell" >&2; exit 1; }
    cat "$STUB/${dir##*/}.json" ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$work/bin"/*

devshell_json() { # PATH-PREFIX then NAME=VALUE pairs
  local path=$1
  shift
  jq -n --arg path "$path" '
    $ARGS.positional
    | map(index("=") as $i | {key: .[:$i], value: {type: "exported", value: .[$i + 1:]}})
    | from_entries
    | {variables: (. + {
        PATH: {type: "exported", value: $path},
        HOME: {type: "exported", value: "/homeless-shelter"},
        TMPDIR: {type: "exported", value: "/build"},
        shellHook: {type: "exported", value: "touch hook-ran"},
        NOT_EXPORTED: {type: "var", value: "1"} }),
       bashFunctions: {genericBuild: "true"}}
  ' --args "$@"
}

new_repo() { # DIR: a git work tree with a tracked flake.nix
  mkdir -p "$1"
  git -C "$1" init -q
  echo '{ outputs = _: { }; }' >"$1/flake.nix"
  git -C "$1" add flake.nix
}

# dash when available, to catch bash-only syntax in the env file.
posix_sh=$(command -v dash || command -v sh)
failed=0
# Claude Code may give each event its own env file and sources them in order.
mkdir "$work/envs"
env_file=$work/envs/1-session-start

run_hook() { # CWD
  local out
  out=$(cd "$work" && printf '{"cwd": "%s"}' "$1" \
    | env -i PATH="$work/bin:$PATH" STUB="$STUB" CLAUDE_ENV_FILE="$env_file" HOME="$work" bash "$work/bin/devshell-env" 2>&1)
  local code=$?
  if [[ $code -ne 0 || -n $out ]]; then
    echo "FAIL: hook in $1 exited $code with output: $out"
    failed=1
  fi
}

# Evaluates EXPR in sh after sourcing the env files, starting from a fixed base env.
check() { # NAME EXPECTED EXPR
  local got
  got=$(env -i PATH=/base/bin BASE=base FOO=base-foo HOME=/home/u TMPDIR=/tmp/u "$posix_sh" -c 'for f in "$1"/*; do . "$f"; done; '"$3" _ "$work/envs" 2>&1)
  if [[ $got != "$2" ]]; then
    echo "FAIL: $1"
    echo "  expected: $2"
    echo "  got:      $got"
    failed=1
  fi
}

lines() { cat "$work/envs"/* 2>/dev/null | wc -l | tr -d ' '; }
base_env="/base/bin|base-foo|base|unset"
base_expr='printf "%s|%s|%s|%s" "$PATH" "$FOO" "$BASE" "${ONLY_A-unset}"'

mkdir -p "$work/plain"
echo '{ outputs = _: { }; }' >"$work/plain/flake.nix"
new_repo "$work/a"
mkdir -p "$work/a/sub/deeper"
new_repo "$work/b"
new_repo "$work/broken"
mkdir -p "$work/elsewhere"
devshell_json "/store/a/bin" "FOO=it's \"a\"
line2" "ONLY_A=1" "lower=x" >"$STUB/a.json"
devshell_json "/store/b/bin" "FOO=b" >"$STUB/b.json"

(cd "$work" && printf '{"cwd": "%s"}' "$work/a" | env -i PATH="$work/bin:$PATH" STUB="$STUB" HOME="$work" bash "$work/bin/devshell-env")
[[ $(lines) == 0 ]] || { echo "FAIL: wrote without CLAUDE_ENV_FILE"; failed=1; }

run_hook "$work/plain"
[[ ! -f $STUB/nix-argv ]] || { echo "FAIL: evaluated a flake outside git"; failed=1; }
check "a flake outside git is ignored" "$base_env" "$base_expr"

run_hook "$work/elsewhere"
check "outside any flake nothing is applied" "$base_env" "$base_expr"

rm -f "$work/envs"/*
run_hook "$work/a/sub/deeper"
check "devShell of the enclosing flake" "/store/a/bin:/base/bin|it's \"a\"
line2|1|x" 'printf "%s|%s|%s|%s" "$PATH" "$FOO" "$ONLY_A" "$lower"'
check "sandbox values and shellHook are dropped" "/home/u|/tmp/u|unset|unset|unset" \
  'printf "%s|%s|%s|%s|%s" "$HOME" "$TMPDIR" "${shellHook-unset}" "${NOT_EXPORTED-unset}" "$(command -v genericBuild || echo unset)"'
grep -q -- '--no-write-lock-file' "$STUB/nix-argv" || { echo "FAIL: may write flake.lock"; failed=1; }
grep -q "$work/a#devShells.x86_64-linux.default" "$STUB/nix-argv" || { echo "FAIL: wrong installable: $(cat "$STUB/nix-argv")"; failed=1; }
[[ ! -e $work/hook-ran && ! -e $work/a/hook-ran ]] || { echo "FAIL: shellHook ran"; failed=1; }

n=$(lines)
: >"$STUB/nix-argv"
run_hook "$work/a"
[[ $(lines) == "$n" && ! -s $STUB/nix-argv ]] || { echo "FAIL: re-evaluated the same flake"; failed=1; }

run_hook "$work/b"
check "switching flakes undoes the previous one" "/store/b/bin:/base/bin|b|unset|unset" \
  'printf "%s|%s|%s|%s" "$PATH" "$FOO" "${ONLY_A-unset}" "${lower-unset}"'

run_hook "$work/broken"
check "a failing flake leaves the base env" "$base_env" "$base_expr"

n=$(lines)
run_hook "$work/elsewhere"
[[ $(lines) == "$n" ]] || { echo "FAIL: wrote again with nothing to undo"; failed=1; }

run_hook "$work/a"
run_hook "$work/elsewhere"
check "leaving a flake restores the base env" "$base_env" "$base_expr"

# The session start applied a; the first cd gets a fresh file of its own.
rm -f "$work/envs"/*
run_hook "$work/a"
env_file=$work/envs/2-cwd-changed
run_hook "$work/elsewhere"
check "a fresh env file still undoes an earlier one" "$base_env" "$base_expr"
run_hook "$work/b"
check "a fresh env file switches flakes" "/store/b/bin:/base/bin|b|base|unset" "$base_expr"

if ((failed)); then exit 1; fi
echo "all devshell-env tests passed"
