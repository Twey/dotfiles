{ config, pkgs, ... }:
{
  networking.hostName = "ingwaz";
  networking.hostId = "33ae908f";
  networking.wireless.enable = true;
  networking.interfaces.wlp59s0.useDHCP = true;
}
