{ config, lib, pkgs, ... }:

# TODO
# - website

{
  imports = [
    ../../modules/base.nix
    ../../modules/linode.nix
    ../../modules/services/rainloop.nix
    ../../modules/mailserver
    ./twey.nix
    ./elle.nix
    ./secrets.nix.secret
  ];

  networking.hostName = "sowilo"; # Define your hostname.
  networking.domain = "twey.co.uk";
  networking.firewall.allowedTCPPorts = [ 80 443 993 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  # yellow prompt (mostly copied from the default)
  programs.bash.promptInit = ''
    # Provide a nice prompt if the terminal supports it.
    if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
      PROMPT_COLOR="1;31m"
      let $UID && PROMPT_COLOR="1;33m"
      if [ -n "$INSIDE_EMACS" -o "$TERM" == "eterm" -o "$TERM" == "eterm-color" ]; then
        # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
        PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
      else
        PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
      fi
      if test "$TERM" = "xterm"; then
        PS1="\[\033]2;\h:\u:\w\007\]$PS1"
      fi
    fi
  '';

  mailserver = {
    enable = true;
    autoconfig.enable = true;
    fqdn = "mail.twey.co.uk";
    useFsLayout = true;
    hierarchySeparator = "/";
    localDnsResolver = false; # use Unbound, above
    vmailUserName = "vmail";
    vmailGroupName = "vmail";

    # 3 = Let's Encrypt
    certificateScheme = 3;

    enableImap = true;
    enablePop3 = true;
    enableImapSsl = true;
    enablePop3Ssl = true;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    # whether to scan inbound emails for viruses (note that this requires at least
    # 1 Gb RAM for the server. Without virus scanning 256 MB RAM should be plenty)
    virusScanning = false;
  };

  nixpkgs.overlays = [
    (self: super: {
      inherit (pkgs.callPackage ../../packages/rainloop { })
        rainloop-community rainloop-standard;
    })
  ];

  services.postfix.hostname = lib.mkForce "sowilo.twey.co.uk";

  security.acme.acceptTerms = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.mysql.settings.mysqld.bind-address = "127.0.0.1";
}
