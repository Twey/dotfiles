# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../modules/base.nix
      ../modules/uefi.nix
      ../modules/workstation.nix
      ../modules/laptop.nix
    ];

  networking.hostName = "eiwaz"; # Define your hostname.
  networking.interfaces.wlan0.useDHCP = true;

  boot.kernelPackages = pkgs.linuxPackages_6_0;
  boot.kernelParams = [ "i915.enable_psr=0" ];
  # this currently breaks suspend; track https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1990700
  # since I'd like to be able to use my 5G
  boot.blacklistedKernelModules = [ "mtk_t7xx" ];

  # Set your time zone.
  time.timeZone = "Europe/London";

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.video.hidpi.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver.dpi = 200;
  #environment.variables = {
  #  GDK_SCALE = "1.0";
  #  GDK_DPI_SCALE = "1.0";
  #  _JAVA_OPTIONS = "-Dsun.java2d.uiScale=1.0";
  #};

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  #   useXkbConfig = true; # use xkbOptions in tty.
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

