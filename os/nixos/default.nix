{ config, pkgs, nixpkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

  environment.systemPackages = with pkgs; [
    google-drive-ocamlfuse
  ];

  system.stateVersion = "23.05";
}

