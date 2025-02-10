{ ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos-gui
    ./hardware-configuration.nix
  ];

  networking.hostName = "fenrir";
}
