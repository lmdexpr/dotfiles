# PreToolUse hook (Claude Code / Codex): ask for confirmation before a shell
# command writes to a remote repository, unless the target is in the allow list.
# Prints nothing for anything else, so normal permission handling applies.
#   publish-guard            ask (permissionDecision "ask")
#   publish-guard --strict   deny instead, for hosts that cannot ask
#
# Which commands are checked: rules JSON ($PUBLISH_GUARD_DEFAULT_RULES, plus
# ~/.config/publish-guard/rules.json if present). Each rule names a target
# resolver below; a new kind of command only needs a new rule.
# Allow list: ~/.config/publish-guard/allow, one HOST/OWNER/REPO per line,
# `*` as a wildcard, `#` comments. Example: github.com/someone/notes

decision=ask
[[ "${1:-}" == --strict ]] && decision=deny

emit_ask() {
  local r=$1
  [[ $decision == deny ]] && r+=$'\n'"Blocked by publish-guard --strict: ask the user to run it, or to add the target to the allow list."
  jq -n --arg d "$decision" --arg r "$r" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  exit 0
}

input=$(cat)
# The shell tool's input differs between hosts: a string `command`, an argv
# array (e.g. ["bash", "-lc", "..."]), or `cmd`. Non-shell tools have none.
cmd=$(jq -r '
  (.tool_input.command // .tool_input.cmd // empty)
  | if type == "array" then
      (if length >= 3 and (.[0] | test("(^|/)(ba|z|da)?sh$")) and (.[1] | test("^-[a-z]*c$"))
       then .[2] else join(" ") end)
    elif type == "string" then . else empty end' <<<"$input")
cwd=$(jq -r '.tool_input.workdir // .cwd // empty' <<<"$input")
[[ -n "$cmd" ]] || exit 0
[[ -d "$cwd" ]] || cwd=$PWD

in_list() { # needle items...
  local n=$1 x; shift
  for x in "$@"; do [[ "$x" == "$n" ]] && return 0; done
  return 1
}

[[ -n "${PUBLISH_GUARD_DEFAULT_RULES:-}" ]] || emit_ask "publish-guard: PUBLISH_GUARD_DEFAULT_RULES is not set; confirm manually"
rule_files=("$PUBLISH_GUARD_DEFAULT_RULES")
local_rules=${PUBLISH_GUARD_LOCAL_RULES:-$HOME/.config/publish-guard/rules.json}
[[ -f "$local_rules" ]] && rule_files+=("$local_rules")
rules=$(jq -cs '{commands: (map(.commands // {}) | add), rules: (map(.rules // []) | add)}' "${rule_files[@]}" 2>/dev/null) ||
  emit_ask "publish-guard: cannot read rules (${rule_files[*]}); confirm manually"

# Fast path: none of the ruled commands appear.
mapfile -t cmds < <(jq -r '[.rules[].cmd] | unique[]' <<<"$rules")
hit=0
for c in "${cmds[@]}"; do
  re="(^|[^[:alnum:]_-])${c}([[:space:]]|\$)"
  [[ "$cmd" =~ $re ]] && { hit=1; break; }
done
((hit)) || exit 0

# Fail closed: an unexpected error past the fast path asks instead of letting
# the command through.
trap 'emit_ask "publish-guard: internal error at line $LINENO; confirm manually"' ERR

allow_file=${PUBLISH_GUARD_ALLOW:-$HOME/.config/publish-guard/allow}
reasons=()

ask() { reasons+=("$1"); }

allowed() { # HOST/OWNER/REPO
  local target=$1 line
  [[ -f "$allow_file" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%%#*}
    line=${line//[[:space:]]/}
    [[ -n "$line" ]] || continue
    # shellcheck disable=SC2053 # glob match is intended
    [[ "$target" == $line ]] && return 0
  done <"$allow_file"
  return 1
}

check_target() { # HOST/OWNER/REPO what
  allowed "$1" || ask "$2: $1 is not in the allow list"
  return 0
}

# HOST/OWNER/REPO for a git remote URL, or empty.
url_target() {
  local url=$1 host path
  if [[ "$url" =~ ^(https?|ssh|git)://([^@/]+@)?([^/:]+)(:[0-9]+)?/(.+)$ ]]; then
    host=${BASH_REMATCH[3]}; path=${BASH_REMATCH[5]}
  elif [[ "$url" =~ ^([^@/]+@)?([^/:]+):(.+)$ ]]; then
    host=${BASH_REMATCH[2]}; path=${BASH_REMATCH[3]}
  else
    return 0
  fi
  path=${path%/}; path=${path%.git}
  printf '%s/%s' "$host" "$path"
}

check_url() { # url what
  local t
  t=$(url_target "$1")
  if [[ -n "$t" ]]; then check_target "$t" "$2"; else ask "$2: cannot tell where '$1' points"; fi
  return 0
}

# --- target resolvers: (dir what args-after-the-matched-words...) ---

resolve_origin() {
  local dir=$1 what=$2 url
  url=$(git -C "$dir" remote get-url --push origin 2>/dev/null) || true
  if [[ -n "$url" ]]; then check_url "$url" "$what"; else ask "$what: no origin remote in $dir"; fi
  return 0
}

resolve_git_remote() {
  local dir=$1 what=$2; shift 2
  local remote="" a url=""
  for a in "$@"; do
    [[ "$a" == -* ]] && continue
    remote=$a; break
  done
  if [[ -z "$remote" ]]; then
    remote=$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || true
    remote=${remote%%/*}
    [[ -n "$remote" ]] || remote=origin
  fi
  if git -C "$dir" remote get-url "$remote" >/dev/null 2>&1; then
    url=$(git -C "$dir" remote get-url --push "$remote" 2>/dev/null) || true
  elif [[ "$remote" == *:* || "$remote" == */* ]]; then
    url=$remote
  fi
  if [[ -n "$url" ]]; then check_url "$url" "$what"; else ask "$what: unknown remote '$remote' in $dir"; fi
  return 0
}

resolve_repo_arg() { # dir what OWNER/REPO|HOST/OWNER/REPO
  local repo=${3#https://}
  case "$repo" in
    */*/*) check_target "$repo" "$2" ;;
    */*) check_target "github.com/$repo" "$2" ;;
    *) ask "$2: cannot tell the repository from '$repo'" ;;
  esac
  return 0
}

resolve_gh_repo() {
  local dir=$1 what=$2; shift 2
  local args=("$@") repo="" i
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[i]}" in
      -R | --repo) repo=${args[i + 1]:-} ;;
      --repo=*) repo=${args[i]#--repo=} ;;
    esac
  done
  # `gh repo <act> [REPO]` takes the repository as its first positional.
  if [[ -z "$repo" && "$what" == "gh repo "* && -n "${args[0]:-}" && "${args[0]}" != -* ]]; then repo=${args[0]}; fi
  if [[ -n "$repo" ]]; then resolve_repo_arg "$dir" "$what" "$repo"; else resolve_origin "$dir" "$what"; fi
  return 0
}

resolve_gh_api() {
  local dir=$1 what=$2; shift 2
  local args=("$@") method="" endpoint="" writes=0 i
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[i]}" in
      -X | --method) method=${args[i + 1]:-}; ((i += 1)) ;;
      --method=*) method=${args[i]#--method=} ;;
      -f | -F | --field | --raw-field | --input) writes=1; ((i += 1)) ;;
      --field=* | --raw-field=* | --input=*) writes=1 ;;
      -H | --header | -q | --jq | -t | --template | -p | --preview | --hostname | --cache) ((i += 1)) ;;
      -*) ;;
      *) [[ -n "$endpoint" ]] || endpoint=${args[i]} ;;
    esac
  done
  method=${method^^}
  if [[ -z "$method" ]]; then [[ $writes == 1 ]] && method=POST || method=GET; fi
  [[ "$method" == GET || "$method" == HEAD ]] && return 0
  if [[ "$endpoint" =~ (^|/)repos/([^/]+/[^/?]+) ]]; then
    check_target "github.com/${BASH_REMATCH[2]}" "gh api $method $endpoint"
  else
    ask "gh api $method $endpoint: no repository in the endpoint"
  fi
  return 0
}

resolve() { # target dir what args...
  local target=$1; shift
  case "$target" in
    git-remote) resolve_git_remote "$@" ;;
    origin) resolve_origin "$@" ;;
    gh-repo) resolve_gh_repo "$@" ;;
    gh-api) resolve_gh_api "$@" ;;
    none) ask "$2" ;;
    *) ask "$2: unknown target resolver '$target' in rules" ;;
  esac
  return 0
}

strip_quotes() { local t=$1; t=${t#[\"\']}; t=${t%[\"\']}; printf '%s' "$t"; }

# Split into simple commands on ; && || | and newlines (quotes not honored:
# good enough to find the commands, and anything odd ends up asked about).
segs=${cmd//&&/$'\n'}
segs=${segs//||/$'\n'}
segs=${segs//;/$'\n'}
segs=${segs//|/$'\n'}
dir=$cwd
while IFS= read -r seg; do
  read -ra words <<<"$seg"
  ((${#words[@]})) || continue
  toks=()
  for w in "${words[@]}"; do toks+=("$(strip_quotes "$w")"); done
  # Skip leading env assignments.
  while ((${#toks[@]})) && [[ "${toks[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do toks=("${toks[@]:1}"); done
  ((${#toks[@]})) || continue

  c=${toks[0]}
  if [[ "$c" == cd ]]; then
    t=${toks[1]:-$HOME}; t=${t/#\~/$HOME}; [[ "$t" == /* ]] || t="$dir/$t"; dir=$t
    continue
  fi
  in_list "$c" "${cmds[@]}" || continue

  # Leading options of the command: a directory option and value options.
  dir_opt=$(jq -r --arg c "$c" '.commands[$c].dir_option // empty' <<<"$rules")
  mapfile -t value_opts < <(jq -r --arg c "$c" '.commands[$c].value_options // [] | .[]' <<<"$rules")
  cdir=$dir i=1
  while ((i < ${#toks[@]})) && [[ "${toks[i]}" == -* ]]; do
    if [[ -n "$dir_opt" && "${toks[i]}" == "$dir_opt" ]]; then
      t=${toks[i + 1]:-}; t=${t/#\~/$HOME}; [[ "$t" == /* ]] || t="$cdir/$t"; cdir=$t; ((i += 2))
    elif in_list "${toks[i]}" "${value_opts[@]}"; then
      ((i += 2))
    else
      ((i += 1))
    fi
  done
  sub=${toks[i]:-} act=${toks[i + 1]:-}

  # First matching rule; act-less rules consume only the subcommand.
  m=$(jq -r --arg c "$c" --arg s "$sub" --arg a "$act" '
    first(.rules[] | select(.cmd == $c and (.sub | index($s)) != null
      and (if .act then (.act | index($a)) != null else true end))
      | "\(.target)\t\(if .act then 2 else 1 end)") // empty' <<<"$rules")
  [[ -n "$m" ]] || continue
  target=${m%%$'\t'*} used=${m#*$'\t'}
  what="$c $sub"; ((used == 2)) && what+=" $act"
  resolve "$target" "$cdir" "$what" "${toks[@]:i+used}"
done <<<"$segs"

((${#reasons[@]})) || exit 0

reason="Writes to a remote repository outside the allow list:"
for r in "${reasons[@]}"; do reason+=$'\n'"- $r"; done
emit_ask "$reason"
