{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.snappymail;
  instance = name: { package, php-package, user, group, vhost, location, ... }: let
    user-name = if user == null then "snappymail-${name}" else user;
    location' = if lib.hasPrefix "/" location then location else "/${location}";
    location'' = if lib.hasSuffix "/" location' then location' else "${location'}/";

  in {
    users = {
      ${if user != null then null else user-name} = {
        isSystemUser = true;
        group = group;
        description = "SnappyMail user for ${name}";
        createHome = true;
        home = "/var/lib/snappymail/${name}";
      };
    };

    pools."snappymail-${name}" = {
      user = user-name;
      group = group;
      settings = {
        "env[SNAPPYMAIL_DATA_DIR]" = config.users.users.${user-name}.home;
        "listen.owner" = user-name;
        "listen.group" = group;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 5;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
      phpEnv."PATH" = lib.makeBinPath [ php-package ];
      phpOptions = ''
        upload_max_filesize = 40m
        post_max_size = 49M
      '';
    };

    vhosts.${vhost} = {
      extraConfig = "client_max_body_size 50m;";
      locations.${location''} = {
        alias = "${package}/";
        index = "index.php";
        extraConfig = ''
          location ~ \.php$ {
            include       ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param SCRIPT_NAME /$1;
            fastcgi_param DOCUMENT_URI /$1;
            fastcgi_pass  unix:${config.services.phpfpm.pools."snappymail-${name}".socket};
          }
        '';
      };
    };
  };
in
{
  options.services.snappymail = mkOption {
    default = { };
    description = ''
      Named instances of the SnappyMail webmail client to run.
    '';
    type = types.attrsOf (types.submodule {
      options = {
        package = mkOption {
          default = pkgs.snappymail;
          defaultText = "pkgs.snappymail";
          type = types.package;
          description = ''
            SnappyMail package to use.
          '';
        };

        php-package = mkOption {
          default = pkgs.php;
          defaultText = "pkgs.php";
          type = types.package;
          description = ''
            PHP package to use.
          '';
        };

        user = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = ''
            Name of the user to run as.  Pass `null` to create a new
            dedicated user named `snappymail-<instance name>` with home
            under `/var/lib/snappymail`.
          '';
        };

        group = mkOption {
          default = "nginx";
          type = types.str;
          description = ''
            Name of the group to run as.
          '';
        };

        vhost = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = ''
            Name of the nginx virtual host on which to expose SnappyMail.
            Pass `null` to disable nginx integration.
          '';
        };

        location = mkOption {
          default = "/";
          type = types.str;
          description = ''
            HTTP location at which SnappyMail will be exposed.
          '';
        };
      };
    });
  };

  config = let
    c = mapAttrsToList instance cfg;
    vhosts = catAttrs "vhosts" c;
  in mkIf (cfg != { }) {
    systemd.tmpfiles.rules = [ "d /var/lib/snappymail 0755 root root - -" ];
    users.users = mkMerge (catAttrs "users" c);
    services.phpfpm.pools = mkMerge (catAttrs "pools" c);
    services.nginx.enable = builtins.length vhosts > 0;
    services.nginx.virtualHosts = mkMerge vhosts;
  };
}
