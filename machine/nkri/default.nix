{ pkgs, ... }: {
  imports = [
    ../../os/nixos
    ./hardware-configuration.nix
  ];

  programs.zsh.enable = true;

  users.users.lmdexpr = {
    isNormalUser = true;
    initialPassword = "p4ssw0rd";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  networking.hostName = "nkri";
}
