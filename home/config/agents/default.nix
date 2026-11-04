{ pkgs, ... }:
let
  agents = pkgs.callPackage ./package.nix { };
  skill = "skills/analyze-workflow-harness";
  herdrSkill = "skills/herdr/SKILL.md";
in
{
  imports = [ ./publish-guard ./devshell-env ];

  home.packages = [ agents.waitCommands ];

  home.file = {
    ".claude/CLAUDE.md".source = "${agents}/CLAUDE.md";
    ".codex/AGENTS.md".source = "${agents}/CLAUDE.md";

    ".agents/${skill}/SKILL.md".source = "${agents}/${skill}/SKILL.md";
    ".claude/${skill}/SKILL.md".source = "${agents}/${skill}/SKILL.md";

    ".agents/${skill}/record.sh" = {
      source = "${agents}/${skill}/record.sh";
      executable = true;
    };
    ".claude/${skill}/record.sh" = {
      source = "${agents}/${skill}/record.sh";
      executable = true;
    };

    ".agents/${herdrSkill}".source = "${agents}/${herdrSkill}";
    ".claude/${herdrSkill}".source = "${agents}/${herdrSkill}";
  };
}
