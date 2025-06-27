{ pkgs, username, nixpkgs-master, ... }:
let
  pkgs-master = import nixpkgs-master { system = pkgs.system; config = pkgs.config; };
in
{
  imports = [
    ../config/zsh
    ../config/git
    ../config/neovim
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

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

    wl-clipboard

    kubectl
    talosctl
    argocd
    kustomize
    kubernetes-helm

    nil

    pkgs-master.claude-code

    w3m
  ];
}
