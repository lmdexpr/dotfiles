{ pkgs, ... }:
let
  hostName = "svartalfheimr";
in 
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos-cli
    ./hardware-configuration.nix
  ];

  networking = { inherit hostName; };
}
