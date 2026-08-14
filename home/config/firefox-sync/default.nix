{ pkgs, lib, hostname, ... }:
# `ffsclient login` is a manual one-time step, not covered here.
let
  ffsclient = lib.getExe pkgs.firefox-sync-client;
in
lib.mkIf (hostname == "svartalfheimr") {
  home.packages = [ pkgs.firefox-sync-client ];

  systemd.user.services.ffsclient-refresh = {
    Unit.Description = "Refresh Firefox Sync (ffsclient) session token";
    Service = {
      Type = "oneshot";
      ExecStart = "${ffsclient} refresh";
    };
  };

  systemd.user.timers.ffsclient-refresh = {
    Unit.Description = "Periodic Firefox Sync session refresh";
    Timer = {
      OnCalendar = "*-*-* 06,18:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
