{ pkgs , ... }:

{
  imports = [
    ../config/zsh
    ../config/git
    ../config/wezterm
    ../config/neovim
  ];

  home = {
    username = "lmdexpr";
    homeDirectory = "/home/lmdexpr";

    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zsh.enable = true;
  };

  home.packages = with pkgs; [
    jq
    fzf
    rlwrap
    hackgen-font
    online-judge-tools
  ];
}
