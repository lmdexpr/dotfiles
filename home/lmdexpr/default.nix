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

    fzf.enable = true;
  };

  home.packages = with pkgs; [
    nodePackages.npm
    hackgen-font
    jq
    rlwrap
    ripgrep
    fd
    tree-sitter
    online-judge-tools
  ];
}
