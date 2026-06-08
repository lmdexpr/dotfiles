{
  config,
  pkgs,
  username,
  ...
}:
{
  system.stateVersion = "25.05";

  programs.zsh.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    initialPassword = "p4ssw0rd";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
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
      enabled = "fcitx5";
      type = "fcitx5";

      fcitx5.addons = with pkgs; [ fcitx5-anthy ];
    };
  };
  services.dbus.packages = [ config.i18n.inputMethod.package ];

  fonts.packages = with pkgs; [
    font-awesome

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    fira-code
    fira-code-symbols
    nerd-fonts.fira-code

    powerline-fonts
    powerline-symbols
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
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
