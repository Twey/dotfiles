{ config, pkgs, ... }:
{ services.xserver =
  { enable = true;
    libinput =
    { enable            = true;
      additionalOptions =
      ''
        Option "TappingButtonMap" "lmr"
        Option "CircularScrolling" "on"
        Option "CircScrollTrigger" "0"
      ''; };
    synaptics.enable = false;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "compose:caps";
    windowManager.xmonad =
    { enable = true;
      enableContribAndExtras = true; };
    displayManager.sddm =
    { enable = true; };
    videoDrivers = [ "intel" ];
    inputClassSections =
    [ ''
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
      '' ]; }; }
