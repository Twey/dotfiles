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

  # purple prompt (mostly copied from the default)
  programs.bash.promptInit = ''
    # Provide a nice prompt if the terminal supports it.
    if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
      PROMPT_COLOR="1;31m"
      let $UID && PROMPT_COLOR="1;35m"
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

  virtualisation.docker = {
    enable = true;
    package = (import <nixpkgs-unstable> { }).docker_24;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

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
