{ ... }:
{
  home.file = {
    ".claude/CLAUDE.md".source = ./user.md;
    ".codex/AGENTS.md".source = ./user.md;

    ".agents/skills/analyze-workflow-harness/SKILL.md".source =
      ./skills/analyze-workflow-harness/SKILL.md;
    ".claude/skills/analyze-workflow-harness/SKILL.md".source =
      ./skills/analyze-workflow-harness/SKILL.md;
  };
}
