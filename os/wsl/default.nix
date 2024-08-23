{ config, lib, pkgs, ... }:
let
  main-user = "nixos";
in
{
  programs.zsh.enable = true;

  users.users."${main-user}" = {
    shell = pkgs.zsh;
  };

  environment.sessionVariables = rec {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  time.timeZone = "Asia/Tokyo";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  system.stateVersion = "24.05";
}
