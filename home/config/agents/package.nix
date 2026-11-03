{ lib, runCommandLocal, writeShellApplication, symlinkJoin, bash, jq, git, curl, coreutils, gnused }:
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

  waitCommands = symlinkJoin {
    name = "agents-wait-commands";
    paths = [
      (waitCommand "forgejo-wait-status" [ curl jq git coreutils gnused ])
      (waitCommand "argocd-wait-app" [ jq coreutils ])
    ];
  };

  skillDir = "skills/analyze-workflow-harness";
in
runCommandLocal "agents" {
  passthru = {
    inherit publishGuard waitCommands;
    tests.wait = runCommandLocal "agents-wait-test" { nativeBuildInputs = [ bash jq coreutils gnused ]; } ''
      bash ${./wait/test.sh} ${./wait} && touch $out
    '';
  };
} ''
  mkdir -p $out/${skillDir} $out/bin
  cp ${./user.md} $out/CLAUDE.md
  cp ${./skills/analyze-workflow-harness/SKILL.md} $out/${skillDir}/SKILL.md
  install -m755 ${./skills/analyze-workflow-harness/record.sh} $out/${skillDir}/record.sh
  ln -s ${lib.getExe publishGuard} $out/bin/publish-guard
  ln -s ${waitCommands}/bin/* $out/bin/
''
