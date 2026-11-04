{ config, lib, pkgs, ... }:
let
  publishGuard = (pkgs.callPackage ../package.nix { }).publishGuard;
  mergeHook = pkgs.callPackage ../merge-hook.nix { };

  hookPath = "${config.home.homeDirectory}/.local/bin/publish-guard";
in
{
  home.file.".local/bin/publish-guard".source = lib.getExe publishGuard;

  home.activation.publishGuardHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${mergeHook {
      file = ".claude/settings.json";
      event = "PreToolUse";
      path = hookPath;
      entry = {
        matcher = "Bash";
        hooks = [{ type = "command"; command = hookPath; timeout = 10; }];
      };
    }}
    # Codex cannot answer "ask", so it gets --strict (deny). Tool names differ
    # there, so no matcher: the hook ignores calls without a shell command.
    ${mergeHook {
      file = ".codex/hooks.json";
      event = "PreToolUse";
      path = hookPath;
      entry.hooks = [{ type = "command"; command = "${hookPath} --strict"; timeout = 10; }];
    }}
  '';
}
