# Claude Code SessionStart/CwdChanged hook: append the environment of the
# nearest flake's devShell to $CLAUDE_ENV_FILE so that Bash tool calls see it.
# Only what the flake itself declares is used: no .envrc, no shellHook.
# Any failure leaves the environment untouched.

[[ -n ${CLAUDE_ENV_FILE:-} ]] || exit 0

input=$(cat)
dir=$(jq -r '.new_cwd // .cwd // empty' <<<"$input" 2>/dev/null) || exit 0
[[ $dir == /* && -d $dir ]] || exit 0

# Without git, nix copies the whole directory into the world-readable store,
# untracked secret files included.
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0

flake=$dir
until [[ -f $flake/flake.nix ]]; do
  [[ ! $flake -ef $top && $flake != / ]] || exit 0
  flake=$(dirname "$flake")
done

json=$(nix --extra-experimental-features 'nix-command flakes' print-dev-env --json --no-write-lock-file \
  "$flake#devShells.$DEVSHELL_SYSTEM.default" 2>/dev/null) || exit 0

# The ignored names follow what `nix develop` leaves to the calling shell.
exports=$(jq -r '
  def prepended: ["PATH", "XDG_DATA_DIRS"];
  def ignored: [
    "BASHOPTS", "HOME", "NIX_BUILD_TOP", "NIX_ENFORCE_PURITY", "NIX_LOG_FD",
    "NIX_REMOTE", "OLDPWD", "PPID", "SHELLOPTS", "SSL_CERT_FILE", "TEMP",
    "TEMPDIR", "TERM", "TMP", "TMPDIR", "TZ", "UID", "shellHook"
  ];
  .variables
  | to_entries[]
  | select(.value.type == "exported" and (.key | test("^[A-Za-z_][A-Za-z0-9_]*$")))
  | select(.key as $k | ignored | index($k) | not)
  | if (.key as $k | prepended | index($k))
    then "export \(.key)=\(.value.value | @sh)\"${\(.key):+:$\(.key)}\""
    else "export \(.key)=\(.value.value | @sh)"
    end
' <<<"$json" 2>/dev/null) || exit 0
[[ -n $exports ]] || exit 0

# Claude Code clears what CwdChanged wrote on the next cd, but never what
# SessionStart wrote, so the variables apply only while inside the flake.
# The block is plain POSIX sh since the Bash tool may run the user's zsh.
root="'${flake//\'/\'\\\'\'}'"
{
  echo "case \$PWD in $root | $root/*)"
  echo "$exports"
  echo ";; esac"
} >>"$CLAUDE_ENV_FILE"
