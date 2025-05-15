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
      levels = [
        [ 0 0 43 ]
        [ 1 43 60 ]
        [ 2 60 65 ]
        [ 3 65 69 ]
        [ 4 69 73 ]
        [ 5 73 79 ]
        [ 7 79 32767 ]
      ];
    };
  };

  networking = { inherit hostName; };
}
