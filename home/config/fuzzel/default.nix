{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "HackGen Console NF:size=12";
        terminal = "wezterm";
        dpi-aware = "yes";
        layer = "overlay";
      };
      colors = {
        background = "2e3440e6";
        text = "eceff4ff";
        match = "88c0d0ff";
        selection = "4c566aff";
        selection-text = "eceff4ff";
        selection-match = "8fbcbbff";
      };
    };
  };
}
