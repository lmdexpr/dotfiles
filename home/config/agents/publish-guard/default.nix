{ config, lib, pkgs, ... }:
let
  publishGuard = pkgs.writeShellApplication {
    name = "publish-guard";
    runtimeInputs = with pkgs; [ jq git ];
    text = ''
      : "''${PUBLISH_GUARD_DEFAULT_RULES:=${./rules.json}}"
    '' + builtins.readFile ./publish-guard.sh;
  };

  hookPath = "${config.home.homeDirectory}/.local/bin/publish-guard";

  # Both settings files are also written by the agents themselves, so they
  # cannot be store symlinks. Merge in place instead: drop entries that run
  # hookPath, then append the current one (idempotent across switches).
  # FILE is relative to $HOME, resolved when the activation runs.
  mergeHook = file: entry: ''
    settings="$HOME"/${lib.escapeShellArg file}
    run mkdir -p "$(dirname "$settings")"
    [ -f "$settings" ] || run sh -c 'echo "{}" > "$1"' _ "$settings"
    tmp=$(mktemp "$settings.XXXXXX")
    ${lib.getExe pkgs.jq} --arg path ${lib.escapeShellArg hookPath} --argjson entry ${lib.escapeShellArg (builtins.toJSON entry)} '
      .hooks.PreToolUse = (
        [ (.hooks.PreToolUse // [])[]
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
  '';
in
{
  home.file.".local/bin/publish-guard".source = lib.getExe publishGuard;

  home.activation.publishGuardHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${mergeHook ".claude/settings.json" {
      matcher = "Bash";
      hooks = [{ type = "command"; command = hookPath; timeout = 10; }];
    }}
    # Codex cannot answer "ask", so it gets --strict (deny). Tool names differ
    # there, so no matcher: the hook ignores calls without a shell command.
    ${mergeHook ".codex/hooks.json" {
      hooks = [{ type = "command"; command = "${hookPath} --strict"; timeout = 10; }];
    }}
  '';
}
