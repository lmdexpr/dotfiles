usage="argocd-wait-app [--timeout SECONDS] [--interval SECONDS] [NAMESPACE/]APP REVISION"
help="Waits until the Argo CD Application is Synced to REVISION (a commit, prefix allowed) and Healthy.
success: Synced to REVISION, Healthy, and no sync operation running.
failure: a sync to REVISION failed, the app is Degraded at REVISION, or the Application cannot be read.
timeout: neither happened in time.
Defaults: --timeout $timeout --interval $interval, NAMESPACE argocd.
Reads the Application with kubectl get only, using the current kubectl context."
parse_args "$@"

app=${args[0]} revision=${args[1]}
namespace=argocd
if [[ $app == */* ]]; then namespace=${app%%/*} app=${app#*/}; fi
[[ -n $namespace && -n $app && -n $revision ]] || finish failure "empty namespace, app or revision; usage: $usage"
name="$namespace/$app@$revision"
command -v kubectl >/dev/null || finish failure "kubectl is not in PATH"

# shellcheck disable=SC2016 # a jq program, not shell
judge='
  def at_rev: any(.[]?; startswith($rev));
  (.status // {}) as $s
  | ($s.operationState // {}) as $op
  | ($s.sync.status // "Unknown") as $sync
  | ($s.health.status // "Unknown") as $health
  | ([$s.sync.revision // empty] + ($s.sync.revisions // []) | at_rev) as $synced_rev
  | ([$op.syncResult.revision // empty, $op.operation.sync.revision // empty]
      + ($op.syncResult.revisions // []) + ($op.operation.sync.revisions // []) | at_rev) as $op_rev
  | "sync \($sync) at \([$s.sync.revision // empty] + ($s.sync.revisions // []) | map(.[0:12]) | join(",")), health \($health)" as $now
  | if ($op.phase | IN("Running", "Terminating")) then ["pending", "\($now), operation \($op.phase)"]
    elif $op_rev and ($op.phase | IN("Failed", "Error")) then
      ["failure", "sync \($op.phase): \($op.message // "" | split("\n") | first // "")"]
    elif $synced_rev and $sync == "Synced" and $health == "Healthy" then ["success", $now]
    elif $synced_rev and $sync == "Synced" and $health == "Degraded" then ["failure", $now]
    else ["pending", $now]
    end
  | @tsv'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

check() {
  local json
  if ! json=$(kubectl get applications.argoproj.io "$app" --namespace "$namespace" --output json 2>"$tmp/err"); then
    summary="$name: $(head -n1 "$tmp/err")"
    # These will not fix themselves; anything else (e.g. an API server hiccup) is retried.
    case $(cat "$tmp/err") in
      *NotFound* | *[Ff]orbidden* | *"doesn't have a resource type"*) state=failure ;;
    esac
    return 0
  fi
  IFS=$'\t' read -r state summary < <(jq -r --arg rev "$revision" "$judge" <<<"$json")
  summary="$name: $summary"
}

poll
