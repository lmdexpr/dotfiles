{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wpaperd
  ];

  xdg.configFile."wpaperd/wallpaper.toml" = {
    source = ./wallpaper.toml;
  };
}
