{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 25;

        modules-left = [ "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "temperature" "backlight" "pulseaudio" "tray" "battery" ];

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
    style = builtins.readFile ./style.css;
  };

  # waybar用のツールをインストール
  home.packages = with pkgs; [
    pavucontrol
    brightnessctl
  ];
}
