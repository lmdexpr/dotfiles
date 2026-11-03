usage="forgejo-wait-status [--timeout SECONDS] [--interval SECONDS] HOST/OWNER/REPO COMMIT"
help="Waits until every commit status (e.g. Forgejo Actions) of COMMIT has finished.
success: all succeeded. failure: any did not, or the commit cannot be read. timeout: some are still pending.
Defaults: --timeout $timeout --interval $interval. HOST may be prefixed with http:// or https:// (default).
Auth: FORGEJO_TOKEN, else git's credential helper for HOST, else anonymous."
parse_args "$@"

repo_arg=${args[0]} ref=${args[1]}
scheme=https
if [[ $repo_arg == http://* ]]; then scheme=http; fi
repo_path=${repo_arg#*://}
repo_path=${repo_path%/}
repo_path=${repo_path%.git}
[[ $repo_path =~ ^([^/]+)/([^/]+)/([^/]+)$ ]] || finish failure "repository must be HOST/OWNER/REPO, got '$repo_arg'"
host=${BASH_REMATCH[1]}
api_base="$scheme://$host/api/v1/repos/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
name="${BASH_REMATCH[2]}/${BASH_REMATCH[3]}@$ref"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl_quote() { local s=${1//\\/\\\\}; printf '"%s"' "${s//\"/\\\"}"; }

# Credentials reach curl as a config file on stdin, never on its command line.
: >"$tmp/auth"
if [[ -n ${FORGEJO_TOKEN:-} ]]; then
  printf 'header = %s\n' "$(curl_quote "Authorization: token $FORGEJO_TOKEN")" >"$tmp/auth"
else
  cred=$(printf 'protocol=%s\nhost=%s\n\n' "$scheme" "$host" |
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=true SSH_ASKPASS=true git -c credential.interactive=false credential fill 2>/dev/null) || cred=""
  user=$(sed -n 's/^username=//p' <<<"$cred")
  pass=$(sed -n 's/^password=//p' <<<"$cred")
  if [[ -n $pass ]]; then printf 'user = %s\n' "$(curl_quote "$user:$pass")" >"$tmp/auth"; fi
  unset cred pass
fi

# GET API_PATH: on 200 sets `body` and returns 0.
# Otherwise sets `summary` (and `state` to failure for client errors that retrying cannot fix) and returns 1.
api() {
  local code
  code=$(curl -sS -m 30 -K - -H 'Accept: application/json' -o "$tmp/body" -w '%{http_code}' \
    "$api_base$1" <"$tmp/auth" 2>"$tmp/err") || code=000
  body=$(cat "$tmp/body" 2>/dev/null) || body=""
  rm -f "$tmp/body"
  case $code in
    200) return 0 ;;
    000) summary="$name: request failed: $(head -n1 "$tmp/err")" ;;
    401 | 403 | 404 | 422)
      state=failure
      summary="$name: HTTP $code $(jq -r '.message // empty' <<<"$body" 2>/dev/null | head -n1 || true)" ;;
    *) summary="$name: HTTP $code" ;;
  esac
  return 1
}

# The combined status holds the latest status per context.
# shellcheck disable=SC2016 # a jq program, not shell
judge='
  map({context, status: (.status // .state)}) as $all
  | ($all | map(select(.status == "pending"))) as $pending
  | ($all | map(select(.status | IN("pending", "success", "warning", "skipped") | not))) as $bad
  | if ($all | length) == 0 then ["pending", "no statuses yet"]
    elif ($pending | length) > 0 then
      ["pending", "\($pending | length)/\($all | length) pending: \($pending | map(.context) | join(", "))"]
    elif ($bad | length) > 0 then
      ["failure", "\($bad | length)/\($all | length) failed: \($bad | map("\(.context) (\(.status))") | join(", "))"]
    else ["success", "\($all | length)/\($all | length) succeeded"]
    end
  | @tsv'

# Resolved once, so a ref that moves while waiting does not change what is waited for.
sha=""

check() {
  if [[ -z $sha ]]; then
    api "/git/commits/$ref" || return 0
    sha=$(jq -r '.sha // empty' <<<"$body")
    [[ -n $sha ]] || { summary="$name: no sha in the commit response"; return 0; }
    name="$name (${sha:0:12})"
  fi

  local page=1 statuses='[]' total got
  while :; do
    api "/commits/$sha/status?limit=50&page=$page" || return 0
    total=$(jq -r '.total_count // 0' <<<"$body")
    got=$(jq '.statuses // [] | length' <<<"$body")
    statuses=$(jq -c --argjson acc "$statuses" '$acc + (.statuses // [])' <<<"$body")
    ((got > 0 && $(jq length <<<"$statuses") < total)) || break
    page=$((page + 1))
  done

  IFS=$'\t' read -r state summary < <(jq -r "$judge" <<<"$statuses")
  summary="$name: $summary"
}

poll
