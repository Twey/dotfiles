{ config, pkgs, ... }:

{
  programs = {
    aria2.enable = true;
    bat.enable = true;
    command-not-found.enable = true;
    home-manager.enable = true;

    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
    };
  
    git = {
      enable = true;
      userName = "James ‘Twey’ Kay";
      userEmail = "twey@twey.co.uk";
      delta.enable = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableNixDirenvIntegration = true;
    };
  };
  
  services.lorri.enable = true;

  xsession = {
    enable = true;
    initExtra = ''
      export MOZ_USE_XINPUT2=1

      xsetroot -cursor_name right_ptr &
      picom -i0.8 -b -f -D2 -I0.1 -O0.1 --no-fading-openclose --focus-exclude "class_g = 'XScreenSaver'" &
      feh --bg-scale ~/Images/wallpaper.jpeg &
      xscreensaver -no-splash &
    '';
  };
  
  home = rec {
    username = "twey";
    homeDirectory = "/home/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "20.09";

    packages = with pkgs; [
      bc
      conky
      direnv
      dzen2
      emacs
      fd
      feh
      firefox
      pavucontrol
      picom
      ripgrep
      rustChannels.nightly.rust
      xfce.terminal
      xscreensaver
    ];
  };
}
