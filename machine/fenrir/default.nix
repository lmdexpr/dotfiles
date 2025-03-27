{ pkgs, ... }:
let
  hostName = "fenrir";
in 
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos-plasma
    ./hardware-configuration.nix
  ];

  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };

    thinkfan = {
      enable = true;
    };
  };

  networking = { inherit hostName; };
}
