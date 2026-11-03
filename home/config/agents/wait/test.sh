# Tests for the wait-* commands with stubbed curl, git, kubectl and sleep.
# Usage: bash test.sh [DIR containing poll.sh and the commands]
set -uo pipefail

src=${1:-$(dirname "${BASH_SOURCE[0]}")}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"

for cmd in forgejo-wait-status argocd-wait-app; do
  { echo 'set -o errexit -o nounset -o pipefail'; cat "$src/poll.sh" "$src/$cmd.sh"; } >"$work/bin/$cmd"
done

# Each stub answers from $STUB: one response per call, the last one repeating.
cat >"$work/bin/curl" <<'EOF'
out="" url=""
echo "$*" >>"$STUB/curl-argv"
while (($#)); do
  case $1 in -o) out=$2; shift 2 ;; -w | -H | -K | -m) shift 2 ;; -*) shift ;; *) url=$1; shift ;; esac
done
cat >"$STUB/curl-config"
n=0
while IFS=$'\t' read -r pattern code body; do
  [[ $url == *"$pattern"* ]] || continue
  n=$((n + 1))
  last="$code"$'\t'"$body"
  [[ $n -gt $(cat "$STUB/count-${pattern//\//_}" 2>/dev/null || echo 0) ]] && break
done <"$STUB/routes"
echo "$n" >"$STUB/count-${pattern//\//_}"
printf '%s' "${last#*$'\t'}" >"$out"
printf '%s' "${last%%$'\t'*}"
EOF
cat >"$work/bin/git" <<'EOF'
[[ -f $STUB/cred ]] || exit 128
cat "$STUB/cred"
EOF
cat >"$work/bin/kubectl" <<'EOF'
echo "$*" >>"$STUB/kubectl-argv"
c=$(( $(cat "$STUB/kube-count" 2>/dev/null || echo 0) + 1 ))
echo "$c" >"$STUB/kube-count"
line=$(sed -n "${c}p" "$STUB/kube"); [[ -n $line ]] || line=$(tail -n1 "$STUB/kube")
rc=${line%%$'\t'*} payload=${line#*$'\t'}
if ((rc == 0)); then printf '%s\n' "$payload"; else printf '%s\n' "$payload" >&2; fi
exit "$rc"
EOF
echo ':' >"$work/bin/sleep"
chmod +x "$work/bin"/*

failed=0
STUB=""

new_case() {
  STUB=$(mktemp -d "$work/case.XXXX")
  : >"$STUB/routes"
}

expect() { # CODE OUTPUT-PATTERN COMMAND ARGS...
  local want_code=$1 want_out=$2 out code
  shift 2
  out=$(env -i PATH="$work/bin:$PATH" TMPDIR="${TMPDIR:-/tmp}" STUB="$STUB" HOME="$STUB" ${FORGEJO_TOKEN:+FORGEJO_TOKEN="$FORGEJO_TOKEN"} bash "$work/bin/$1" "${@:2}" 2>&1)
  code=$?
  # shellcheck disable=SC2053 # glob match is intended
  if [[ $code != "$want_code" || $out != $want_out || $(wc -l <<<"$out") != 1 ]]; then
    echo "FAIL: $*"$'\n'"  want $want_code '$want_out'"$'\n'"  got  $code '$out'"
    failed=1
  else
    echo "ok: $* -> $out"
  fi
}

route() { printf '%s\t%s\t%s\n' "$@" >>"$STUB/routes"; }
commit='{"sha":"0123456789abcdef0123456789abcdef01234567"}'
status() { # TOTAL CONTEXT=STATE...
  local total=$1 s="" cs
  shift
  for cs in "$@"; do s+="${s:+,}{\"context\":\"${cs%=*}\",\"status\":\"${cs#*=}\"}"; done
  printf '{"total_count":%s,"statuses":[%s]}' "$total" "$s"
}
repo=git.example.test/owner/repo

# --- forgejo-wait-status ---

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 2 build=success test=warning)"
expect 0 'success: owner/repo@main (0123456789ab): 2/2 succeeded' forgejo-wait-status "$repo" main

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 0)"
route /status 200 "$(status 2 build=pending test=pending)"
route /status 200 "$(status 2 build=success test=pending)"
route /status 200 "$(status 2 build=success test=success)"
expect 0 'success: *2/2 succeeded' forgejo-wait-status "$repo" main
[[ $(cat "$STUB/count-_status") == 4 ]] || { echo "FAIL: expected 4 status polls"; failed=1; }

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 2 build=failure test=pending)"
route /status 200 "$(status 2 build=failure test=success)"
expect 1 'failure: *1/2 failed: build (failure)' forgejo-wait-status "$repo" main

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 1 build=pending)"
expect 2 'timeout: gave up after 0s; owner/repo@main (0123456789ab): 1/1 pending: build' forgejo-wait-status --timeout 0 "$repo" main

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 0)"
expect 2 'timeout: *no statuses yet' forgejo-wait-status --timeout=0 --interval=5 "$repo" main

new_case
route /git/commits/ 404 '{"message":"object does not exist"}'
expect 1 'failure: owner/repo@nope: HTTP 404 object does not exist' forgejo-wait-status "$repo" nope

new_case
route /git/commits/ 502 'bad gateway'
route /git/commits/ 200 "$commit"
route /status 500 ''
route /status 200 "$(status 1 build=success)"
expect 0 'success: *1/1 succeeded' forgejo-wait-status "https://$repo.git" main

new_case
route /git/commits/ 200 "$commit"
route 'page=1' 200 "$(status 3 a=success b=success)"
route 'page=2' 200 "$(status 3 c=error)"
expect 1 'failure: *1/3 failed: c (error)' forgejo-wait-status "$repo" main

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 1 build=success)"
FORGEJO_TOKEN=s3cret-token expect 0 'success: *' forgejo-wait-status "$repo" main
if grep -q s3cret "$STUB/curl-argv" || ! grep -q 'header = "Authorization: token s3cret-token"' "$STUB/curl-config"; then
  echo "FAIL: FORGEJO_TOKEN must reach curl via its config only"; failed=1
fi

new_case
route /git/commits/ 200 "$commit"
route /status 200 "$(status 1 build=success)"
printf 'protocol=https\nhost=git.example.test\nusername=someone\npassword=pa"ss\n' >"$STUB/cred"
expect 0 'success: *' forgejo-wait-status "$repo" main
if grep -q 'pa"ss' "$STUB/curl-argv" || ! grep -qF 'user = "someone:pa\"ss"' "$STUB/curl-config"; then
  echo "FAIL: helper credentials must reach curl via its config only"; failed=1
fi
grep -q "^-sS -m 30 -K - .* https://git.example.test/api/v1/repos/owner/repo/git/commits/main$" "$STUB/curl-argv" ||
  { echo "FAIL: unexpected API URL: $(head -n1 "$STUB/curl-argv")"; failed=1; }

new_case
expect 1 'failure: repository must be HOST/OWNER/REPO*' forgejo-wait-status owner/repo main
expect 1 'failure: expected 2 arguments; usage: forgejo-wait-status *' forgejo-wait-status "$repo"
expect 1 'failure: --interval needs a positive number of seconds*' forgejo-wait-status --interval 0 "$repo" main
expect 1 'failure: unknown option --bogus*' forgejo-wait-status --bogus "$repo" main

# --- argocd-wait-app ---

rev=0123456789abcdef0123456789abcdef01234567
old=fedcba9876543210fedcba9876543210fedcba98
app() { # SYNC REVISION HEALTH [OP-PHASE OP-REVISION [MESSAGE]]
  jq -cn --arg sync "$1" --arg rev "$2" --arg health "$3" --arg phase "${4:-Succeeded}" --arg oprev "${5:-$2}" --arg msg "${6:-}" '
    {status: {sync: {status: $sync, revision: $rev}, health: {status: $health},
      operationState: {phase: $phase, message: $msg, syncResult: {revision: $oprev}, operation: {sync: {revision: $oprev}}}}}'
}
kube() { printf '%s\t%s\n' "$@" >>"$STUB/kube"; }

new_case
kube 0 "$(app Synced "$rev" Healthy Succeeded "$old")"
expect 0 'success: argocd/web@0123456: sync Synced at 0123456789ab, health Healthy' argocd-wait-app web 0123456
grep -q -- '^get applications.argoproj.io web --namespace argocd --output json$' "$STUB/kubectl-argv" ||
  { echo "FAIL: unexpected kubectl call: $(cat "$STUB/kubectl-argv")"; failed=1; }

new_case
kube 0 "$(app Synced "$old" Healthy)"
kube 0 "$(app OutOfSync "$old" Healthy)"
kube 0 "$(app Synced "$rev" Progressing Running "$rev")"
kube 0 "$(app Synced "$rev" Healthy Running "$rev")"
kube 0 "$(app Synced "$rev" Progressing)"
kube 0 "$(app Synced "$rev" Healthy)"
expect 0 'success: apps/web@*' argocd-wait-app apps/web "$rev"
grep -q -- '--namespace apps' "$STUB/kubectl-argv" || { echo "FAIL: namespace not passed"; failed=1; }
[[ $(cat "$STUB/kube-count") == 6 ]] || { echo "FAIL: expected 6 polls, got $(cat "$STUB/kube-count")"; failed=1; }

new_case
kube 0 "$(app Synced "$old" Healthy)"
expect 2 'timeout: gave up after 0s; argocd/web@0123456: sync Synced at fedcba987654, health Healthy' argocd-wait-app --timeout 0 web 0123456

new_case
kube 0 "$(app OutOfSync "$old" Healthy Failed "$rev" $'one or more objects failed to apply\nsecond line')"
expect 1 'failure: argocd/web@0123456: sync Failed: one or more objects failed to apply' argocd-wait-app web 0123456

new_case
kube 0 "$(app OutOfSync "$rev" Healthy Failed "$old" 'old failure')"
expect 2 'timeout: *sync OutOfSync*' argocd-wait-app --timeout 0 web 0123456

new_case
kube 0 "$(app Synced "$rev" Degraded)"
expect 1 'failure: argocd/web@0123456: sync Synced at 0123456789ab, health Degraded' argocd-wait-app web 0123456

new_case
kube 0 "$(app Synced "$old" Degraded)"
expect 2 'timeout: *health Degraded' argocd-wait-app --timeout 0 web 0123456

new_case
kube 0 "$(jq -cn --arg a "$old" --arg b "$rev" '{status: {sync: {status: "Synced", revisions: [$a, $b]}, health: {status: "Healthy"}}}')"
expect 0 'success: *sync Synced at fedcba987654,0123456789ab, health Healthy' argocd-wait-app web "$rev"

new_case
kube 1 'Error from server (NotFound): applications.argoproj.io "web" not found'
expect 1 'failure: argocd/web@0123456: Error from server (NotFound): *' argocd-wait-app web 0123456

new_case
kube 1 'Unable to connect to the server: dial tcp: i/o timeout'
kube 0 "$(app Synced "$rev" Healthy)"
expect 0 'success: *' argocd-wait-app web 0123456

new_case
kube 1 'Unable to connect to the server: dial tcp: i/o timeout'
expect 2 'timeout: *Unable to connect*' argocd-wait-app --timeout 0 web 0123456

new_case
expect 1 'failure: expected 2 arguments*' argocd-wait-app web

exit $failed
