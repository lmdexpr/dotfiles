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

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  programs.fuse = {
    userAllowOther = true;
  };

  environment.systemPackages = with pkgs; [
    google-drive-ocamlfuse
  ];
  imports = [ ../../modules/services/google-drive-ocamlfuse.nix ];
  services.google-drive-ocamlfuse = {
    enable = true;
    main-user = main-user;
  };

  system.stateVersion = "23.05";
}

