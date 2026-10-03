{ config, lib, pkgs, username, ... }:
let
  # Root-only, created by hand (this repo is public):
  #   install -d -m 700 /etc/nixos-upgrade
  #   echo 'DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...' > /etc/nixos-upgrade/discord.env
  #   chmod 600 /etc/nixos-upgrade/discord.env
  webhookEnv = "/etc/nixos-upgrade/discord.env";

  notify = pkgs.writeShellApplication {
    name = "nixos-upgrade-notify";
    runtimeInputs = with pkgs; [ coreutils curl jq systemd ];
    text = ''
      result="$1"
      host=${config.networking.hostName}
      state=/var/lib/nixos-upgrade-notify/last-system
      current=$(readlink -f /run/current-system)

      if [ "$result" = success ]; then
        # Only report when the switch actually changed the system; silence means "nothing new".
        if [ -f "$state" ] && [ "$(cat "$state")" = "$current" ]; then
          exit 0
        fi
        msg=$(printf '[OK] %s: nixos-upgrade switched to %s' "$host" "$(basename "$current")")
      else
        logs=$(journalctl -u nixos-upgrade.service -n 25 --no-pager -o cat | tail -c 1500)
        fence=$(printf '\140\140\140')
        msg=$(printf '[FAIL] %s: nixos-upgrade failed (running %s)\n%s\n%s\n%s' "$host" "$(basename "$current")" "$fence" "$logs" "$fence")
      fi

      jq -n --arg content "$msg" '{content: $content}' \
        | curl -fsS -H 'Content-Type: application/json' --data @- "$DISCORD_WEBHOOK_URL"
      echo "$current" > "$state"
    '';
  };
in
{
  # Nightly: pull master from GitHub (not the local checkout) and switch.
  # Merging a PR on master is the deploy gate.
  system.autoUpgrade = {
    enable = true;
    flake = "github:lmdexpr/dotfiles#svartalfheimr";
    dates = "04:00";
    allowReboot = false;
  };

  # svartalfheimr's disk is a zvol on TrueNAS' HDD pool, shared with other VMs
  # (incl. a Talos control plane). Big builds saturated it on 2026-10-01 and
  # took etcd down, so let builds yield to everything else.
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";

  systemd.services.nixos-upgrade.unitConfig = {
    OnFailure = [ "nixos-upgrade-notify@failure.service" ];
    OnSuccess = [ "nixos-upgrade-notify@success.service" ];
  };

  systemd.services."nixos-upgrade-notify@" = {
    description = "Notify Discord about nixos-upgrade (%i)";
    unitConfig.ConditionPathExists = webhookEnv;
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = webhookEnv;
      StateDirectory = "nixos-upgrade-notify";
      ExecStart = "${lib.getExe notify} %i";
    };
  };

  # Let the user (and Claude running as the user) trigger the upgrade on demand
  # without sudo. Only `start` of this one unit; what it deploys is still master.
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "nixos-upgrade.service" &&
          action.lookup("verb") == "start" &&
          subject.user == "${username}") {
        return polkit.Result.YES;
      }
    });
  '';
}
