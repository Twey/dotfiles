{ config, pkgs, ... }:
{
  services = {
    random-background = {
     enable = true;
     imageDirectory = "%h/.wallpapers";
    };

    xscreensaver.enable = true;
  };

  xsession = {
   enable = true;

   windowManager.xmonad = {
     enable = true;
     enableContribAndExtras = true;
   };
  };
}
