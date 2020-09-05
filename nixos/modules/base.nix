{ ... }:
{
  imports = [ ../hardware-configuration.nix ];

  networking.useDHCP = false;

  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  programs.gnupg.agent.enable = true;
  programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  users.users.twey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
