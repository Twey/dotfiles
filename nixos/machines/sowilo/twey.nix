{ config, lib, pkgs, ... }:
{
  users.groups."twey.co.uk".members = [ "twey.co.uk" "twey" "nginx" ];
  users.users."twey.co.uk" = { };

  services.nginx.virtualHosts = {
    "sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/www";
    };

    "clock.sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/clock";
    };

    "english.sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/english";
    };

    "stuff.sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/twey.co.uk/stuff";
      extraConfig = ''autoindex on;'';
    };

    "mail.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
    };
  };

  security.acme.certs."sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."clock.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."english.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."stuff.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."mail.twey.co.uk".email = "twey@twey.co.uk";

  services.nginx.package = pkgs.nginx.override { withDebug = true; };
  mailserver.domains = [ "twey.co.uk" ];
  services.rainloop."twey.co.uk" = {
    vhost = "mail.twey.co.uk";
    group = "twey.co.uk";
    location = "/rainloop";
  };
  services.mailpile."twey.co.uk" = {
    localPort = 33144;
    vhost = "mail.twey.co.uk";
    location = "/mailpile";
  };

  mailserver.loginAccounts."twey@twey.co.uk" = {
    # mkpasswd -m sha-512 "super secret password"
    hashedPassword = config.secrets.passwords.twey;
    aliases = [ "postmaster@twey.co.uk" "abuse@twey.co.uk" ];
  };
}
