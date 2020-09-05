{ config, lib, pkgs, ... }:
with lib;
let
  file = pkgs.writeTextFile {
    name = "mailserver-autoconfig";
    text = config.mailserver.autoconfig.xml;
    destination = "/mail/config-v1.1.xml";
  };
in
{
  imports = [ ./data.nix ];

  options.mailserver.autoconfig = {
    enable = mkEnableOption "Mozilla-style autoconfig (requires nginx)";

    displayName = mkOption {
      type = types.str;
      default = config.mailserver.fqdn;
      defaultText = "config.mailserver.fqdn";
      description = "The name the user will see for this server.";
    };

    displayShortName = mkOption {
      type = types.str;
      default = config.mailserver.fqdn;
      defaultText = "config.mailserver.autoconfig.displayName";
      description = "A user-visible short name for this server.";
    };
  };

  config = mkIf config.mailserver.autoconfig.enable {
    services.nginx.virtualHosts = mkMerge (map (domain: {
      "autoconfig.${domain}".root = file;
    }) config.mailserver.domains);
  };
}
