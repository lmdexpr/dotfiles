{ pkgs, ... }:
{
  imports = [
    ../gui

    ../config/waybar
    ../config/fuzzel
    ../config/mako
    ../config/swaylock
    ../config/wpaperd
  ];

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    packages = with pkgs; [
      grim
      slurp
      wf-recorder

      networkmanagerapplet
      wlogout
      blueman
      lm_sensors
    ];
  };

  xdg.configFile."niri/config.kdl" = {
    source = ./config.kdl;
    force = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/about" = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
    };
  };
}
