{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.rainloop;
  instance = name: { package, php-package, domain, ... }: let
    home = "/var/lib/rainloop/${name}";
    long-name = "rainloop-${name}";
  in {
    user.name = long-name;
    user.value = {
      isSystemUser = true;
      description = "Rainloop user for ${name}";
      createHome = true;
      inherit home;
    };

    pool.name = long-name;
    pool.value = {
      user = long-name;
      group = "nogroup";
      settings = {
        "env[RAINLOOP_DATA_DIR]" = home;
        "listen.owner" = config.services.nginx.user;
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

    vhost.name = domain;
    vhost.value = {
      extraConfig = ''client_max_body_size 50m;'';
      locations."/" = {
        root = "${package}";
        index = "index.php";
      };
      locations."~ \.php$" = {
        root = "${package}";
        extraConfig = ''
          fastcgi_pass  unix:${config.services.phpfpm.pools.${long-name}.socket};
          fastcgi_index index.php;
          include       ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
  };
in
{
  options.services.rainloop = mkOption {
    default = { };
    description = "TODO";
    type = types.attrsOf (types.submodule {
      options = {
        package = mkOption {
          default = pkgs.rainloop-community;
          defaultText = "pkgs.rainloop-community";
          type = types.package;
          description = ''
            Rainloop package to use.
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

        domain = mkOption {
          type = types.str;
          description = ''
            Virtual host name on which rainloop should be available.
          '';
        };
      };
    });
  };

  config = let
    c = mapAttrsToList instance cfg;
  in mkIf (cfg != { }) {
    system.activationScripts.rainloop = {
      deps = [];
      text = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/lib/rainloop
        ${pkgs.coreutils}/bin/chmod 755 /var/lib/rainloop
      '';
    };
    users.users = listToAttrs (catAttrs "user" c);
    services.phpfpm.pools = listToAttrs (catAttrs "pool" c);
    services.nginx.enable = true;
    services.nginx.virtualHosts = listToAttrs (catAttrs "vhost" c);
  };
}
