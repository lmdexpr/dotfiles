{ pkgs, nixpkgs, ... }:

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
    hackgen-font
    jq
    fzf
    rlwrap
    ripgrep
    fd
    tree-sitter
    online-judge-tools
    notion-app-enhanced
  ];
}
