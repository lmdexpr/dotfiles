{ ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos-cli
    ./hardware-configuration.nix
  ];

  networking.hostName = "svartalfaheimr";
}
