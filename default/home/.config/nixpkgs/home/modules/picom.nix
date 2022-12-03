{ ... }:
{
  services.picom = {
    enable = true;
    inactiveOpacity = 0.8;
    settings.blur = {
      method = "gaussian";
      size = 10;
      deviation = 5.0;
    };
    fade = true;
    fadeDelta = 2;
    fadeSteps = [ 0.1 0.1 ];
    backend = "xrender";
    settings.use-damage = false;
    settings.unredir-if-possible = false;
  };
}
