{ config, pkgs, nixpkgs, ... }:
let
  main-user = "lmdexpr";
in
{
  programs.zsh.enable = true;

  users.users."${main-user}" = {
    isNormalUser = true;
    initialPassword = "p4ssw0rd";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvs6ThdjoxW6TpVk7z69GdKAuCWEFORrlE0Q2YwPnfu Generate by Termius"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRbaJ5Y8AbP86laEUUtfYKMCD4uzel+STeDja2BOZpV nixos@nkri"
    ];
  };

  environment.sessionVariables = rec {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-anthy ];
    };
  };
  services.dbus.packages = [ config.i18n.inputMethod.package ];

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  services.xserver = {
    enable = true;
    layout = "us";

    libinput.enable = true;

    displayManager = { gdm.enable = true; };
    desktopManager = { gnome.enable = true; };
  };
  
  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;

    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    keyboard.qmk.enable = true;
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  system.stateVersion = "23.05";
}
