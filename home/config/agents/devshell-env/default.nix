{ config, lib, pkgs, ... }:
let
  devshellEnv = (pkgs.callPackage ../package.nix { }).devshellEnv;
  mergeHook = pkgs.callPackage ../merge-hook.nix { };

  hookPath = "${config.home.homeDirectory}/.local/bin/devshell-env";
  # A cold devShell may need downloads; past this the session goes on without it.
  hooks = [{ type = "command"; command = hookPath; timeout = 300; }];
in
{
  home.file.".local/bin/devshell-env".source = lib.getExe devshellEnv;

  home.activation.devshellEnvHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatMapStrings (event: mergeHook {
      file = ".claude/settings.json";
      inherit event hookPath;
      entry = { inherit hooks; };
    }) [ "SessionStart" "CwdChanged" ]
  );
}
