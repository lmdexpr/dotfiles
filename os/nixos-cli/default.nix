{ config, pkgs, ... }:
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
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  services.xserver = {
    enable = false;
    xkb.layout = "us";

    displayManager = { gdm.enable = false; };
    desktopManager = { gnome.enable = false; };
  };
  services.libinput.enable = false;
  
  hardware = {
    pulseaudio.enable = false;

    graphics= {
      enable = false;
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

  system.stateVersion = "23.05";
}
