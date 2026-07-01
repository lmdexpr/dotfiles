{
  pkgs,
  username,
  mcp-servers,
  ...
}:
let
  mcp-servers-config = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    source = mcp-servers.lib.mkConfig pkgs {
      programs = {
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
            "/home/${username}/private-notes"
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
    ../config/neovim
    ../config/firefox-sync
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
      enableDefaultConfig = false;
    };

    tmux = {
      enable = true;
      extraConfig = "set -g exit-empty off";
    };
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  home.file = {
    ".claude/CLAUDE.md" = {
      source = ../config/claude/user.md;
    };
  };

  xdg.configFile = {
    "mcphub/servers.json" = mcp-servers-config;
    "claude/servers.json" = mcp-servers-config;
  };

  home.packages = with pkgs; [
    gcc
    nodejs

    lua51Packages.lua
    lua51Packages.luarocks
    lua-language-server

    jq
    rlwrap
    ripgrep
    fd
    tree-sitter

    wl-clipboard

    ghostty.terminfo
    w3m
    claude-code
    gh

    kubectl
    talosctl
    argocd
    kustomize
    kubernetes-helm

    nil
  ];
}
