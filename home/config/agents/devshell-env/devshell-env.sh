# SessionStart / CwdChanged hook (Claude Code): hand the shell tool the
# devShell environment of the flake containing the working directory, by
# appending a POSIX sh block to $CLAUDE_ENV_FILE.
#
# Only the devShell derivation's own variables are used (nix print-dev-env),
# never direnv: .envrc / .envrc.local commonly load tokens. The flake must be
# in a git work tree, so evaluation sees tracked files only and an untracked
# secret file is never copied into the store. shellHook is not run: it is
# arbitrary code with side effects (and often sources .envrc or secrets).
#
# Blocks from SessionStart and CwdChanged are sourced in order, so each one
# first undoes whatever an earlier one applied. Leaving a flake, or a flake
# that fails to evaluate, only undoes. Each event may get its own env file,
# so this file being empty does not mean nothing was applied.
#
# nix is taken from PATH so that it matches the user's daemon and config.

env_file=${CLAUDE_ENV_FILE:-}
[[ -n $env_file ]] || exit 0

cwd=$(jq -r '.cwd // empty' 2>/dev/null) || cwd=""
[[ -n $cwd ]] || cwd=$PWD
cwd=$(cd "$cwd" 2>/dev/null && pwd -P) || exit 0

find_flake() {
  local top d=$cwd
  top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || return 1
  top=$(cd "$top" && pwd -P)
  while :; do
    [[ -f $d/flake.nix ]] && { printf '%s\n' "$d"; return 0; }
    [[ $d == "$top" || $d == / ]] && return 1
    d=$(dirname "$d")
  done
}

shell_quote() { jq -rn --arg v "$1" '$v | @sh'; }

current=""
[[ -f $env_file ]] && current=$(sed -n 's/^__DEVSHELL_ROOT=//p' "$env_file" | tail -n1)

flake=$(find_flake) || flake=""
if [[ -n $flake && $(shell_quote "$flake") == "$current" ]]; then
  exit 0
fi

# shellcheck disable=SC2016 # expanded by the shell that sources the env file
reset='eval "${__DEVSHELL_RESTORE-}"'

dev_env() {
  local nix=(nix --extra-experimental-features 'nix-command flakes')
  local system
  system=$("${nix[@]}" config show system) || return 1
  timeout "${DEVSHELL_ENV_TIMEOUT:-150}" "${nix[@]}" print-dev-env --json --no-write-lock-file \
    "$flake#devShells.$system.default" </dev/null
}

json=""
[[ -n $flake ]] && json=$(dev_env 2>/dev/null) || json=""

if [[ -z $json ]]; then
  [[ $current != "''" ]] || exit 0
  printf '%s\n__DEVSHELL_RESTORE=\n__DEVSHELL_ROOT=%s\n' "$reset" "''" >>"$env_file"
  exit 0
fi

block=$(jq -r --arg root "$flake" --arg reset "$reset" '
  # Build-sandbox values that nix develop does not carry over either.
  ["BASHOPTS", "HOME", "NIX_BUILD_TOP", "NIX_ENFORCE_PURITY", "NIX_LOG_FD", "NIX_REMOTE",
   "OLDPWD", "PPID", "SHELL", "SHELLOPTS", "SSL_CERT_FILE", "TEMP", "TEMPDIR", "TERM",
   "TMP", "TMPDIR", "TZ", "UID", "shellHook"] as $ignored
  | ["PATH", "XDG_DATA_DIRS"] as $prepended
  | [ .variables | to_entries[]
      | select(.value.type == "exported" and (.key | test("^[A-Za-z_][A-Za-z0-9_]*$")))
      | select(.key as $k | $ignored | index($k) | not)
      | {key, value: (.value.value | tostring)} ] as $vars
  | ( $vars | map(.key as $k
        | "if [ -n \"${__DEVSHELL_SAVED_\($k)+x}\" ]; then export \($k)=\"$__DEVSHELL_SAVED_\($k)\"; else unset \($k); fi; unset __DEVSHELL_SAVED_\($k)")
      | join("\n")) as $restore
  | [ $reset, "__DEVSHELL_ROOT=\($root | @sh)", "__DEVSHELL_RESTORE=\($restore | @sh)" ]
    + [ $vars[] | .key as $k
        | "if [ -n \"${\($k)+x}\" ]; then __DEVSHELL_SAVED_\($k)=$\($k); fi",
          if $prepended | index($k)
          then "export \($k)=\(.value | @sh)\"${__DEVSHELL_SAVED_\($k):+:$__DEVSHELL_SAVED_\($k)}\""
          else "export \($k)=\(.value | @sh)" end ]
  | join("\n")
' <<<"$json") || exit 0

printf '%s\n' "$block" >>"$env_file"
