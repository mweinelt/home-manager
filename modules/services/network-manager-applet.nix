{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.network-manager-applet;

in

{
  meta.maintainers = [ maintainers.rycee ];

  options = {
    services.network-manager-applet = {
      enable = mkEnableOption "the Network Manager applet";

      package = mkOption {
        type = types.package;
        default = pkgs.networkmanagerapplet;
        defaultText = literalExample "pkgs.networkmanagerapplet";
        description = "The package to use for the nm-applet binary.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.network-manager-applet = {
      Unit = {
        Description = "Network Manager applet";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = toString (
          [
            "${cfg.package}/bin/nm-applet"
            "--sm-disable"
          ] ++ optional config.xsession.preferStatusNotifierItems "--indicator"
        );
      };
    };
  };
}
