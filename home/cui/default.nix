{ pkgs, username, ... }:
{
  imports = [
    ../config/zsh
    ../config/git
    ../config/neovim
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "24.05";
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
  ];
}
