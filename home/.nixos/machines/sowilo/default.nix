{ config, lib, pkgs, ... }:

# TODO
# - secret management
# - website

let
  simple-mailserver-commit = "066dba1b2ffbbe39dab9b1c3c1d759423b7f7b38";
  simple-mailserver = builtins.fetchTarball {
    # Pick a commit from the branch you are interested in
    url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${simple-mailserver-commit}/nixos-mailserver-${simple-mailserver-commit}.tar.gz";
    # And set its hash
    sha256 = "1ypzj3rjvvmpms37dcbxfrnqrn281nlsy56rr989gkqfmm53mxd6";
  };
in
{
  imports = [
    ../../modules/base.nix
    ../../modules/linode.nix
    ../../modules/services/mailpile.nix
    ../../modules/services/rainloop.nix
    ../../modules/autoconfig
    ./twey.nix
    ./elle.nix
    ./secrets.nix
    simple-mailserver
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

  services.unbound.enable = true;
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
    (self: super: { mailpile = self.callPackage ../../packages/mailpile { }; })
    (self: super: {
      inherit (pkgs.callPackage ../../packages/rainloop { })
        rainloop-community rainloop-standard;
    })
  ];

  security.acme.acceptTerms = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.mysql.bind = "127.0.0.1";
}
