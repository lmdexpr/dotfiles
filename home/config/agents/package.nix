{ lib, runCommandLocal, writeShellApplication, jq, git }:
let
  publishGuard = writeShellApplication {
    name = "publish-guard";
    runtimeInputs = [ jq git ];
    text = ''
      : "''${PUBLISH_GUARD_DEFAULT_RULES:=${./publish-guard/rules.json}}"
    '' + builtins.readFile ./publish-guard/publish-guard.sh;
  };

  skillDir = "skills/analyze-workflow-harness";
in
runCommandLocal "agents" { passthru = { inherit publishGuard; }; } ''
  mkdir -p $out/${skillDir} $out/bin
  cp ${./user.md} $out/CLAUDE.md
  cp ${./skills/analyze-workflow-harness/SKILL.md} $out/${skillDir}/SKILL.md
  install -m755 ${./skills/analyze-workflow-harness/record.sh} $out/${skillDir}/record.sh
  ln -s ${lib.getExe publishGuard} $out/bin/publish-guard
''
