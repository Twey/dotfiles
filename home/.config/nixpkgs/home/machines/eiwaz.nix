{ config, pkgs, ... }:

{
  imports = [ ../modules/base.nix ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "twey";
  home.homeDirectory = "/home/twey";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  gtk.theme = {
    package = pkgs.materia-theme;
    name = "Materia-light";
  };

  services.picom = {
    enable = true;
    inactiveOpacity = 0.8;
    fade = false;
    backend = "glx";
    settings.blur = {
      method = "gaussian";
      size = 10;
      deviation = 5.0;
    };
    settings.use-damage = false;
  };
}
