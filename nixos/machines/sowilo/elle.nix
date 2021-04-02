{ pkgs, lib, config, ... }:
{
  users.groups."elfe.co.uk".members = [ "elle" "elfe.co.uk" "nginx" ];
  users.users."elfe.co.uk" = { };

  services.phpfpm.pools."elfe.co.uk" = {
    user = "elfe.co.uk";
    group = "elfe.co.uk";
    settings = {
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
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.mysql = {
    ensureDatabases = [ "elfe_wordpress" ];
    ensureUsers = [
      {
        name = "elfe.co.uk";
        ensurePermissions."elfe_wordpress.*" = "ALL PRIVILEGES";
      }
    ];
  };

  services.nginx.virtualHosts = {
    "mail.elfe.co.uk" = {
      forceSSL = true;
      enableACME = true;
    };
    "elfe.co.uk" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www/elfe.co.uk";
        index = "index.php";
        tryFiles = "$uri $uri/ /index.php?$args";
      };
      locations."~ \.php$" = {
        root = "/var/www/elfe.co.uk";
        extraConfig = ''
          fastcgi_pass  unix:${config.services.phpfpm.pools."elfe.co.uk".socket};
          fastcgi_index index.php;
          include       ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
    "www.elfe.co.uk" = {
      addSSL = true;
      enableACME = true;
      globalRedirect = "elfe.co.uk";
    };
  };

  services.rainloop."elfe.co.uk".vhost = "mail.elfe.co.uk";
  services.mailpile."elfe.co.uk".localPort = 33145;

  security.acme.certs = {
    "elfe.co.uk".email = "twey@twey.co.uk";
    "www.elfe.co.uk".email = "twey@twey.co.uk";
    "mail.elfe.co.uk".email = "twey@twey.co.uk";
  };

  mailserver.domains = [ "elfe.co.uk" ];
  mailserver.extraVirtualAliases."abuse@elfe.co.uk" = "twey@twey.co.uk";

  mailserver.loginAccounts."elle@elfe.co.uk".hashedPassword =
    config.secrets.passwords.elle;
}
