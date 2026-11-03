# Shared by the wait-* commands, prepended to each of them.
# A command sets `usage` (one line) and `help`, defines `check` (sets `state` to success/failure/pending and `summary`), then calls `poll`.
# Whatever happens, exactly one line is printed and the exit status is 0 (success), 1 (failure) or 2 (timeout).

finish() { # STATE SUMMARY
  case $1 in
    success) echo "success: $2"; exit 0 ;;
    timeout) echo "timeout: $2"; exit 2 ;;
    *) echo "failure: $2"; exit 1 ;;
  esac
}

timeout=1800
interval=10
args=()

parse_args() {
  local seconds='^[0-9]+$' positive='^[1-9][0-9]*$'
  while (($#)); do
    case $1 in
      --timeout)
        [[ ${2:-} =~ $seconds ]] || finish failure "--timeout needs a number of seconds; usage: $usage"
        timeout=$2; shift 2 ;;
      --interval)
        [[ ${2:-} =~ $positive ]] || finish failure "--interval needs a positive number of seconds; usage: $usage"
        interval=$2; shift 2 ;;
      --timeout=* | --interval=*) set -- "${1%%=*}" "${1#*=}" "${@:2}" ;;
      -h | --help) printf "usage: %s\n%s\n" "$usage" "$help"; exit 0 ;;
      --) shift; args+=("$@"); break ;;
      -*) finish failure "unknown option $1; usage: $usage" ;;
      *) args+=("$1"); shift ;;
    esac
  done
  ((${#args[@]} == 2)) || finish failure "expected 2 arguments; usage: $usage"
}

poll() {
  local deadline=$((SECONDS + timeout)) left
  while :; do
    state=pending summary=""
    check
    [[ $state == pending ]] || finish "$state" "$summary"
    left=$((deadline - SECONDS))
    ((left > 0)) || finish timeout "gave up after ${timeout}s; $summary"
    sleep $((interval < left ? interval : left))
  done
}
