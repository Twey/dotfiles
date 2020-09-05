{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mailpile;
  instance = name: { host, port, package, ... }: let
    # gpg-agent won't use a directory with colons
    address = "${host}:${builtins.toString port}";
    long-name = "mailpile-${name}";
    home = "/var/lib/mailpile/${name}";
  in {
    package = package;
    user.name = long-name;
    user.value = {
      isSystemUser = true;
      description = "Mailpile user for ${name}";
      createHome = true;
      inherit home;
    };
    service.name = "mailpile-${name}";
    service.value = {
      description = "Mailpile server for ${name}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = long-name;
        ExecStartPre = "${pkgs.coreutils}/bin/chmod 755 /var/lib/mailpile";
        ExecStart = "${package}/bin/mailpile --www ${address} --wait";
        PermissionsStartOnly = true;
        # mixed - first send SIGINT to main process,
        # then after 2min send SIGKILL to whole group if neccessary
        KillMode = "mixed";
        KillSignal = "SIGINT";  # like Ctrl+C - safe mailpile shutdown
        TimeoutSec = 20;  # wait 20s untill SIGKILL
      };
      environment.MAILPILE_HOME = home;
      environment.GNUPGHOME = "${home}/.gnupg";
    };
  };
in {
  disabledModules = [ "services/networking/mailpile.nix" ];

  options.services.mailpile = mkOption {
    default = { };

    description = "Named instances of Mailpile to run";

    type = types.attrsOf (types.submodule {
      options = {
        host = mkOption {
          default = "127.0.0.1";
          type = types.str;
          description = ''
            Interface to bind to.
          '';
        };

        port = mkOption {
          default = 33144;
          type = types.port;
          description = ''
            Port to listen on.
          '';
        };

        package = mkOption {
          default = pkgs.mailpile;
          defaultText = "pkgs.mailpile";
          type = types.package;
          description = ''
            Mailpile package to use.
          '';
        };
      };
    });

    example = {
      my-app = { port = 33144; };
    };
  };

  config = let
    c = mapAttrsToList instance cfg;
  in {
    environment.systemPackages = catAttrs "package" c;
    users.users = listToAttrs (catAttrs "user" c);
    users.groups = listToAttrs (catAttrs "group" c);
    systemd.services = listToAttrs (catAttrs "service" c);
  };
}
