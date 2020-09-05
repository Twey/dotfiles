{ config, lib, pkgs, ... }:
{
  services.rainloop."twey.co.uk".domain = "rainloop.sowilo.twey.co.uk";

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
    };

    "mailpile.sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = with config.services.mailpile."twey.co.uk";
        "http://${host}:${builtins.toString port}";
    };

    "rainloop.sowilo.twey.co.uk" = {
      forceSSL = true;
      enableACME = true;
    };
  };

  security.acme.certs."sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."clock.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."english.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."stuff.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."mailpile.sowilo.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."mail.twey.co.uk".email = "twey@twey.co.uk";
  security.acme.certs."rainloop.sowilo.twey.co.uk".email = "twey@twey.co.uk";

  mailserver.domains = [ "twey.co.uk" ];
  services.mailpile."twey.co.uk".port = 33144;

  mailserver.loginAccounts."twey@twey.co.uk" = {
    # mkpasswd -m sha-512 "super secret password"
    hashedPassword = config.secrets.passwords.twey;
    aliases = [ "postmaster@twey.co.uk" "abuse@twey.co.uk" ];
  };
}
