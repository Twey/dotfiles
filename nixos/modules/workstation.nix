{ lib, config, pkgs, ... }:
let
  mkX11ConfigForDevice = deviceType: matchIs: let
    cfg = config.services.xserver.libinput;
    xorgBool = v: if v then "on" else "off";
    inherit (lib) optionalString;
  in ''
    Identifier "libinput ${deviceType} configuration"
    MatchDriver "libinput"
    MatchIs${matchIs} "${xorgBool true}"
    ${optionalString (cfg.${deviceType}.dev != null) ''MatchDevicePath "${cfg.${deviceType}.dev}"''}
    Option "AccelProfile" "${cfg.${deviceType}.accelProfile}"
    ${optionalString (cfg.${deviceType}.accelSpeed != null) ''Option "AccelSpeed" "${cfg.${deviceType}.accelSpeed}"''}
    ${optionalString (cfg.${deviceType}.buttonMapping != null) ''Option "ButtonMapping" "${cfg.${deviceType}.buttonMapping}"''}
    ${optionalString (cfg.${deviceType}.calibrationMatrix != null) ''Option "CalibrationMatrix" "${cfg.${deviceType}.calibrationMatrix}"''}
    ${optionalString (cfg.${deviceType}.clickMethod != null) ''Option "ClickMethod" "${cfg.${deviceType}.clickMethod}"''}
    Option "LeftHanded" "${xorgBool cfg.${deviceType}.leftHanded}"
    Option "MiddleEmulation" "${xorgBool cfg.${deviceType}.middleEmulation}"
    Option "NaturalScrolling" "${xorgBool cfg.${deviceType}.naturalScrolling}"
    ${optionalString (cfg.${deviceType}.scrollButton != null) ''Option "ScrollButton" "${toString cfg.${deviceType}.scrollButton}"''}
    Option "ScrollMethod" "${cfg.${deviceType}.scrollMethod}"
    Option "HorizontalScrolling" "${xorgBool cfg.${deviceType}.horizontalScrolling}"
    Option "SendEventsMode" "${cfg.${deviceType}.sendEventsMode}"
    Option "Tapping" "${xorgBool cfg.${deviceType}.tapping}"
    Option "TappingDragLock" "${xorgBool cfg.${deviceType}.tappingDragLock}"
    Option "DisableWhileTyping" "${xorgBool cfg.${deviceType}.disableWhileTyping}"
    ${cfg.${deviceType}.additionalOptions}
  '';
in
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

    libinput.enable = true;

    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "compose:caps";

    inputClassSections = lib.mkForce [
      (mkX11ConfigForDevice "touchpad" "Touchpad")
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

      ''
        Identifier "CharaChorder"
        MatchProduct "CharaChorder 1 Keyboard"
        MatchIsKeyboard "true"
        Driver "evdev"
        Option "xkb_layout" "us"
        Option "xkb_variant" "basic"
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
