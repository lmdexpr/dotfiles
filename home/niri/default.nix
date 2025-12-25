{ pkgs, username, mcp-servers, ... }:
let
  mcp-servers-config = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux
    {
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
      enableDefaultConfig = false;
      matchBlocks = {
        "git.lmdex.pro" = {
          port = 22;
          user = "git";
          proxyCommand = "sh -c 'resolved_ip=$(dig +short %h | head -1); if echo \"$resolved_ip\" | grep -E \"^(192\\.168\\.|10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.)\" ; then nc \"$resolved_ip\" 22; else cloudflared access ssh --hostname %h; fi'";
        };
      };
    };

    fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "HackGen Console NF:size=12";
          terminal = "wezterm";
          dpi-aware = "yes";
          layer = "overlay";
        };
        colors = {
          background = "2e3440e6";
          text = "eceff4ff";
          match = "88c0d0ff";
          selection = "4c566aff";
          selection-text = "eceff4ff";
          selection-match = "8fbcbbff";
        };
      };
    };

    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [ "niri/workspaces" "niri/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "cpu" "memory" "temperature" "backlight" "pulseaudio" "tray" "battery" ];

          "niri/workspaces" = {
            format = "{name}";
          };

          "niri/window" = {
            format = "{title}";
            max-length = 50;
          };

          clock = {
            format = "🕐 {:%Y-%m-%d %H:%M}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "🔇 ";
            format-icons = {
              default = ["🔈" "🔉" "🔊"];
            };
            on-click = "pavucontrol";
          };

          battery = {
            format = "{icon} {capacity}%";
            format-icons = ["🪫" "🔋" "🔋" "🔋" "🔋"];
            states = {
              warning = 30;
              critical = 15;
            };
            format-charging = "⚡ {capacity}%";
            format-plugged = "🔌 {capacity}%";
            on-click = "gnome-power-statistics";
          };

          cpu = {
            format = "💻 {usage}%";
            interval = 2;
          };

          memory = {
            format = "🧠 {percentage}%";
            interval = 2;
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = ["🔅" "🔆"];
            on-scroll-up = "brightnessctl set +5%";
            on-scroll-down = "brightnessctl set 5%-";
          };

          temperature = {
            format = "🌡️ {temperatureC}°C";
            critical-threshold = 80;
            format-critical = "🔥 {temperatureC}°C";
            interval = 2;
          };
        };
      };
      style = ''
        * {
          font-family: HackGen Console NF;
          font-size: 11px;
        }

        window#waybar {
          background-color: rgba(46, 52, 64, 0.8);
          color: #eceff4;
          border-bottom: 2px solid #4c566a;
        }

        #workspaces button {
          padding: 0 8px;
          color: #d8dee9;
          background-color: transparent;
          border-radius: 0;
        }

        #workspaces button.focused {
          background-color: #4c566a;
          color: #88c0d0;
        }

        #window,
        #clock,
        #pulseaudio,
        #network,
        #battery {
          padding: 0 4px;
          margin: 0 1px;
        }

        #cpu,
        #memory,
        #temperature {
          padding: 0 4px;
          margin: 0 1px;
        }
        #temperature {
          margin-right: 12px;
          border-right: 2px solid #4c566a;
        }

        /* ハードウェア制御グループ */
        #backlight,
        #pulseaudio {
          padding: 0 4px;
          margin: 0 1px;
        }
        #pulseaudio {
          margin-right: 12px;
          border-right: 2px solid #4c566a;
        }

        /* システムトレイ */
        #tray {
          padding: 0 4px;
          margin: 0 1px;
        }
        /* 電源グループ */
        #battery {
          padding: 0 8px;
          margin: 0 2px;
        }
      '';
    };
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  home.file = {
    ".claude/CLAUDE.md" = { source = ../config/claude/user.md; };
  };

  xdg.configFile = {
    "mcphub/servers.json" = mcp-servers-config;
    "claude/servers.json" = mcp-servers-config;

    "niri/config.kdl" = {
      source = ./config.kdl;
      force = true;
    };

    "wpaperd/wallpaper.toml".source = ./wallpaper.toml;

    "swaylock/config".source = ./swaylock.config;
  };

  home.packages = with pkgs; [
    gcc
    nodePackages.npm

    lua51Packages.lua
    lua51Packages.luarocks
    lua-language-server

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

    spotify

    remmina

    bitwarden-desktop
    bitwarden-cli

    obsidian

    claude-code

    chromium
    playwright-driver

    grim
    slurp
    wf-recorder

    wpaperd
    swaylock-effects

    # waybar用ツール
    pavucontrol
    networkmanagerapplet
    wlogout
    brightnessctl
    blueman
    lm_sensors
  ];

  services = {
    mako = {
      enable = true;
      settings = {
        font = "HackGen Console NF 11";
        background-color = "#2e3440";
        text-color = "#eceff4";
        border-color = "#88c0d0";
        border-size = 2;
        border-radius = 8;
        default-timeout = 5000;
      };
    };

    swayidle = {
      enable = true;
      timeouts = [
        { timeout = 300; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
        { timeout = 600; command = "niri msg action power-off-monitors"; }
      ];
      events.before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
    };
  };
}
