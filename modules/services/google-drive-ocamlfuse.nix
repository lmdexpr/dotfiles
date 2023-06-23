{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.google-drive-ocamlfuse;
in {
  options.services.google-drive-ocamlfuse = {
    enable = mkEnableOption "google-drive-ocamlfuse service";
    main-user = mkOption {
      type = types.str;
      default = "lmdexpr";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.google-drive-ocamlfuse = {
      description = "FUSE filesystem over Google Drive";
      after = [ "network.target" ];
      serviceConfig = {
        User = cfg.main-user;
        ExecStart = "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse -o allow_other /home/${escapeShellArg cfg.main-user}/GoogleDrive";
        ExecStop = "/run/wrappers/bin/fusermount -u /home/${escapeShellArg cfg.main-user}/GoogleDrive";
        Restart = "always";
        Type = "forking";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
