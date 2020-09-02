{ config, pkgs, ... }:
{
  networking.hostName = "uruz"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
