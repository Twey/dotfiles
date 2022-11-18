{ config, pkgs, ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/workstation.nix
    ../modules/uefi.nix
  ];

  networking.hostName = "thurisaz"; # Define your hostname.
  networking.hostId = "018b1652";

  networking.interfaces.enp3s0.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = ["nvidia"];

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u20n.psf.gz";

  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-label/thurisaz";
    preLVM = true;
    allowDiscards = true;
  };
  boot.extraModulePackages = [ pkgs.linuxPackages.openrazer ];
  boot.kernelModules = [ "razercore" "razermouse" "i2c-dev" "i2c-piix4" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
