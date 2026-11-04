{ lib, stdenv, fetchurl, runCommandLocal, writeShellApplication, symlinkJoin, bash, dash, jq, git, curl, coreutils, gnused }:
let
  publishGuard = writeShellApplication {
    name = "publish-guard";
    runtimeInputs = [ jq git ];
    text = ''
      : "''${PUBLISH_GUARD_DEFAULT_RULES:=${./publish-guard/rules.json}}"
    '' + builtins.readFile ./publish-guard/publish-guard.sh;
  };

  # kubectl is left to the caller's PATH so that it matches their cluster and config.
  waitCommand = name: runtimeInputs: writeShellApplication {
    inherit name runtimeInputs;
    text = builtins.readFile ./wait/poll.sh + builtins.readFile ./wait/${name}.sh;
  };

  # nix is left to the caller's PATH so that it matches their daemon and config.
  devshellEnv = writeShellApplication {
    name = "devshell-env";
    runtimeInputs = [ jq git coreutils ];
    text = ''
      DEVSHELL_SYSTEM=${stdenv.hostPlatform.system}
    '' + builtins.readFile ./devshell-env/devshell-env.sh;
  };

  waitCommands = symlinkJoin {
    name = "agents-wait-commands";
    paths = [
      (waitCommand "forgejo-wait-status" [ curl jq git coreutils gnused ])
      (waitCommand "argocd-wait-app" [ jq coreutils ])
    ];
  };

  skillDir = "skills/analyze-workflow-harness";

  # Keep in step with the herdr version from nixpkgs: the skill documents its CLI.
  herdrSkill = fetchurl {
    url = "https://raw.githubusercontent.com/herdrdev/herdr/2ecf19a92fc3a7fff75b6ce3655ef04f4625ec01/skills/herdr/SKILL.md"; # v0.9.5
    hash = "sha256-+9nVAnZ/ff8pwhFQWgvZujTpgO1MxFYkfircFkKIOYQ=";
  };
in
runCommandLocal "agents" {
  passthru = {
    inherit publishGuard devshellEnv waitCommands;
    tests.wait = runCommandLocal "agents-wait-test" { nativeBuildInputs = [ bash jq coreutils gnused ]; } ''
      bash ${./wait/test.sh} ${./wait} && touch $out
    '';
    tests.devshellEnv = runCommandLocal "agents-devshell-env-test" { nativeBuildInputs = [ bash dash jq git coreutils ]; } ''
      bash ${./devshell-env/test.sh} ${./devshell-env} && touch $out
    '';
  };
} ''
  mkdir -p $out/${skillDir} $out/skills/herdr $out/bin
  cp ${./user.md} $out/CLAUDE.md
  cp ${./skills/analyze-workflow-harness/SKILL.md} $out/${skillDir}/SKILL.md
  install -m755 ${./skills/analyze-workflow-harness/record.sh} $out/${skillDir}/record.sh
  cp ${herdrSkill} $out/skills/herdr/SKILL.md
  ln -s ${lib.getExe publishGuard} $out/bin/publish-guard
  ln -s ${lib.getExe devshellEnv} $out/bin/devshell-env
  ln -s ${waitCommands}/bin/* $out/bin/
''
