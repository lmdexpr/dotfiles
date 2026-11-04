{ config, lib, pkgs, ... }:
let
  devshellEnv = (pkgs.callPackage ../package.nix { }).devshellEnv;
  mergeHook = pkgs.callPackage ../merge-hook.nix { };

  hookPath = "${config.home.homeDirectory}/.local/bin/devshell-env";
  # Covers building a devShell for the first time; later runs hit the store.
  entry.hooks = [{ type = "command"; command = hookPath; timeout = 180; }];
  register = event: mergeHook { file = ".claude/settings.json"; inherit event entry; path = hookPath; };
in
{
  home.file.".local/bin/devshell-env".source = lib.getExe devshellEnv;

  home.activation.devshellEnvHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${register "SessionStart"}
    ${register "CwdChanged"}
  '';
}
