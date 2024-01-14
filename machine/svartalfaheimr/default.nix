{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos
    ./hardware-configuration.nix
  ];

  networking.hostName = "svartalfaheimr";
}
