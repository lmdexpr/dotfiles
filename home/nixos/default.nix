{ pkgs, nixpkgs, ... }:

{
  imports = [
    ../config/zsh
    ../config/git
    ../config/neovim
  ];

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";

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
    jq
    ripgrep
    fd
    tree-sitter
    online-judge-tools
  ];
}
