{ pkgs, ... }:
{
  home.packages = with pkgs; [
    swaylock-effects
  ];

  xdg.configFile."swaylock/config" = {
    source = ./swaylock.config;
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
      { timeout = 600; command = "niri msg action power-off-monitors"; }
    ];
    events.before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
  };
}
