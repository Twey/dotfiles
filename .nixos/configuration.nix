# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./machine.nix # machine-specific settings, symlink to machines/*.nix
      ./fonts.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs"];
  boot.kernelModules = [ "ecryptfs" ];

  services.zfs.trim.enable = true;
  
  # We set this on a per-interface basis
  networking.useDHCP = false;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.inputMethod.enabled = "uim";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    libinput = {
      enable = true;
      additionalOptions = ''MatchIsTouchpad "true"'';
    };

    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "compose:caps";

    inputClassSections = [
      ''
        Identifier "Kensington Expert Mouse"
        MatchProduct "Expert Mouse"
        Driver "libinput"
        Option "ScrollMethod" "button"
        Option "ScrollButton" "8"
      ''

      ''
        Identifier "ErgoDox"
        MatchProduct "ErgoDox EZ"
        MatchIsKeyboard "true"
        Driver "evdev"
        Option "xkb_layout" "us"
        Option "xkb_variant" "basic"
        Option "xkb_options" "compose:caps"
      ''
    ];

    displayManager.lightdm.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  users.users.twey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}

