{ pkgs, ... }:
{
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.timeout = 10;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    extraConfig = ''
      serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
      terminal_input serial;
      terminal_output serial
    '';
  };

  networking.usePredictableInterfaceNames = false;
  networking.interfaces.eth0.useDHCP = true;

  # Linode expects (at least on Debian-based VMs) a local DNS resolver
  services.unbound.enable = true;

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];

  users.users.twey.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa3J8DONjpN71wr085Tkm+G4B9RWFYv8So4BLg1QYbK twey@thurisaz"
  ];
}
