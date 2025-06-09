{ pkgs, username, mcp-servers, nixpkgs-master, ... }:
let
  pkgs-master = import nixpkgs-master { system = pkgs.system; config = pkgs.config; };
  mcp-servers-config = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux
    {
      source = mcp-servers.lib.mkConfig pkgs {
        programs = {
          fetch.enable = true;
          playwright.enable = true;
          filesystem = {
            enable = true;
            args = [ "/home/${username}" ];
          };
        };

        settings.servers = {
          mcp-obsidian = {
            command = "${pkgs.lib.getExe' pkgs.nodejs "npx"}";
            args = [
              "-y"
              "mcp-obsidian"
              "/home/${username}/Documents/private-notes"
            ];
          };
        };
      };

    };
in
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

  home.file = {
    ".claude/CLAUDE.md" = { source = ../config/claude/user.md; };
  };

  xdg.configFile = {
    "mcphub/servers.json" = mcp-servers-config;

    # claude --mcp-config ~/.config/claude/servers.json
    "claude/servers.json" = mcp-servers-config;
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
    pkgs-master.claude-code
    
    chromium
    playwright-driver
  ];
}
