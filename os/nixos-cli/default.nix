{ config, pkgs, username, ... }:
{
  programs.zsh.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    initialPassword = "p4ssw0rd";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvs6ThdjoxW6TpVk7z69GdKAuCWEFORrlE0Q2YwPnfu Generate by Termius"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRbaJ5Y8AbP86laEUUtfYKMCD4uzel+STeDja2BOZpV nixos@nkri"
    ];
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  i18n = {
    inputMethod = {
      enabled = "fcitx5"; type = "fcitx5";

      fcitx5.addons = with pkgs; [ fcitx5-anthy ];
    };
  };
  services.dbus.packages = [ config.i18n.inputMethod.package ];

  fonts.packages = with pkgs; [
    font-awesome

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra

    fira-code
    fira-code-symbols
    nerd-fonts.fira-code

    powerline-fonts
    powerline-symbols

    "${pkgs.fetchzip {
      url  = "https://github.com/yuru7/HackGen/releases/download/v2.10.0/HackGen_NF_v2.10.0.zip";
      hash = "sha256-n0ibIzNIy5tUdC0QEWRRW4S5Byih39agW2IxCiqTLoQ=";
    }}"
  ];

  services.xserver = {
    enable = false;
    xkb.layout = "us";
  };
  
  hardware = {
    keyboard.qmk.enable = true;
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nix.settings.experimental-features = [ 
    "nix-command" 
    "flakes" 
    "pipe-operators"
  ];

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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  system.stateVersion = "25.05";
}
