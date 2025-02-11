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
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      type = "fcitx5";
      fcitx5.addons = [ pkgs.fcitx5-anthy ];
    };
  };

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
    enable = true;
    xkb.layout = "us";

    displayManager = { lightdm.enable = true; };
    desktopManager = { budgie.enable = true; };
  };

  services.libinput.enable = true;
  
  services.printing.enable = true;

  services.dbus.packages = [ config.i18n.inputMethod.package ];
  
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.netatalk = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.cloudflare-warp = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.keyboard.qmk.enable = true;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nix.settings.experimental-features = [ 
    "nix-command" 
    "flakes" 
    "pipe-operators"
  ];

  nixpkgs.config.allowUnfree = true;

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

  systemd.services.libinput-gestures.enable = true;

  system.stateVersion = "24.11";
}
