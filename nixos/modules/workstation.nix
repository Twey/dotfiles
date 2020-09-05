{ config, pkgs, ... }:
{
  imports = [ ./fonts.nix ];

  boot.kernelModules = [ "ecryptfs" ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  i18n.inputMethod.enabled = "uim";

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

    displayManager = {
      lightdm = {
        enable = true;
        greeter.enable = false;
      };

      autoLogin = {
        enable = true;
        user = "twey";
      };
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };
}
