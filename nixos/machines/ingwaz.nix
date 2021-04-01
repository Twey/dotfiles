{ config, pkgs, ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/workstation.nix
    ../modules/laptop.nix
    ../modules/uefi.nix
  ];

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId ="PCI:1:0:0";
  };


  nixpkgs.config.allowUnfree = true;

  networking.hostName = "ingwaz";
  networking.hostId = "33ae908f";
  networking.wireless.enable = true;
  networking.interfaces.wlp59s0.useDHCP = true;

  boot.kernelModules = [ "kvm-intel" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.allowedBridges = [ "virbr0" "hdnbr0" ];
}
