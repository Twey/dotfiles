{ config, lib, pkgs, ... }:
{
  users.groups."twey.co.uk".members = [ "twey.co.uk" "twey" "nginx" ];
  users.users."twey.co.uk" = {
    isNormalUser = true;
    group = "twey.co.uk";
  };

  services.nginx.virtualHosts = {
    "twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      globalRedirect = "twey.io";
    };

    "clock.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/clock";
    };

    "stuff.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/stuff";
      extraConfig = ''autoindex on;'';
    };

    "mail.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
    };

    "twey.io" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.io/www";
    };

    "www.twey.io" = {
      forceSSL = true;
      enableACME = true;
      globalRedirect = "twey.io";
    };

    "entailor.tools" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/entailor.tools";
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.twey.co.uk";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";

      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;

      SMTP_FROM = "admin@vault.twey.co.uk";
      SMTP_FROM_NAME = "twey.co.uk Vaultwarden server";
    };
  };

  services.nginx.virtualHosts."vault.twey.co.uk" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
  };

  security.acme.defaults.email = "twey@twey.co.uk";

  services.matomo = rec {
    enable = true;
    hostname = "stats.entailor.tools";
    nginx.serverName = hostname;
  };

  mailserver.domains = [ "twey.co.uk" ];

  mailserver.loginAccounts."twey@twey.co.uk" = {
    # mkpasswd -m sha-512 "super secret password"
    hashedPassword = config.secrets.passwords.twey;
    aliases = [ "postmaster@twey.co.uk" "abuse@twey.co.uk" ];
  };
}
