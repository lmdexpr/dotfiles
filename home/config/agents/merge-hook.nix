{ lib, jq }:
# Settings files that agents also write themselves cannot be store symlinks.
# Merge in place instead: drop the EVENT entries that run hookPath, then append
# the current one (idempotent across switches).
# FILE is relative to $HOME, resolved when the activation runs.
{ file, event, hookPath, entry }: ''
  settings="$HOME"/${lib.escapeShellArg file}
  run mkdir -p "$(dirname "$settings")"
  [ -f "$settings" ] || run sh -c 'echo "{}" > "$1"' _ "$settings"
  tmp=$(mktemp "$settings.XXXXXX")
  ${lib.getExe jq} --arg event ${lib.escapeShellArg event} --arg path ${lib.escapeShellArg hookPath} --argjson entry ${lib.escapeShellArg (builtins.toJSON entry)} '
    .hooks[$event] = (
      [ (.hooks[$event] // [])[]
        | select([.hooks[]?.command // "" | startswith($path)] | any | not) ]
      + [ $entry ])
  ' "$settings" > "$tmp"
  if cmp -s "$tmp" "$settings"; then
    rm -f "$tmp"
  else
    # mktemp creates 0600; keep the file's own mode.
    chmod --reference="$settings" "$tmp"
    run mv "$tmp" "$settings"
    rm -f "$tmp"
  fi
''
