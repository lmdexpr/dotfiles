{ pkgs, lib, hostname, ... }:
# Firefox Sync (ffsclient) support for the cross-device history pipeline.
#
# The history-collector itself lives in the `private` flake (systemd *user*
# timer, reads history via ffsclient and writes host-local JSONL). This module
# only owns the dotfiles side of the contract:
#   1. make `ffsclient` available for the one-time interactive login/refresh, and
#   2. keep the FxA session token fresh so the collector never falls back to
#      no-op due to an expired token.
#
# Session lives at the ffsclient default ~/.config/firefox-sync-client.secret
# (no FFS_SESSION override), which the collector shares. Login is a manual,
# one-time step (not declarative — it needs the account password / FxA email
# confirmation):
#   ffsclient login <email> <password> --device-name svartalfheimr
#
# Scoped to svartalfheimr: the `cui` profile is shared with skelton (WSL), which
# has no collector, so there is nothing to feed there.
let
  ffsclient = lib.getExe pkgs.firefox-sync-client;
in
lib.mkIf (hostname == "svartalfheimr") {
  home.packages = [ pkgs.firefox-sync-client ];

  # Renew the OAuth session token on a schedule. `refresh` no-ops cleanly when
  # the token is still valid and fails harmlessly (logged) when no session
  # exists yet, so this is safe to land before the first login.
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
