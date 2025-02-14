{ ... }:
let
  hostName = "svartalfaheimr";
in 
{
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
