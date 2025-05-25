{ pkgs, username, ... }:
{
  imports = [
    ../config/zsh
    ../config/git
    ../config/wezterm
    ../config/neovim
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf.enable = true;

    ssh = {
      enable = true;
      extraConfig = ''
        Host git.lmdex.pro
        Port 22
        User git
        ProxyCommand sh -c 'resolved_ip=$(dig +short %h | head -1); if echo "$resolved_ip" | grep -E "^(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)"; then nc "$resolved_ip" 22; else cloudflared access ssh --hostname %h; fi'
      '';
    };
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "25.05";
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
    cloudflared
    dig

    nil

    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ 
        kdePackages.wrapQtAppsHook 
      ];
    }))
    
    discord

    remmina

    bitwarden-desktop
    bitwarden-cli

    obsidian

    aider-chat
  ];
}
