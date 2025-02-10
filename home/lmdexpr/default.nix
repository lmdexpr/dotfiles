{ pkgs, ... }:

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

    stateVersion = "25.05";
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
    gcc
    nodePackages.npm

    lua51Packages.lua
    lua51Packages.luarocks

    jq
    rlwrap
    ripgrep
    fd
    tree-sitter

    kubectl
    talosctl
    argocd
    kustomize
    kubernetes-helm

    nil

    hackgen-font

    vivaldi
  ];
}
