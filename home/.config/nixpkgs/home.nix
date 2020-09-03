{ config, pkgs, ... }:

rec {
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
  
  services = {
    lorri.enable = true;

    picom = {
      enable = true;
      inactiveOpacity = "0.8";
      blur = true;
      fade = true;
      fadeDelta = 2;
      fadeSteps = [ "0.1" "0.1" ];
      backend = "xrender";
    };

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

    profileExtra = "export MOZ_USE_XINPUT2=1";
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

    keyboard = null;
    
    packages = with pkgs; [
      bc
      conky
      direnv
      dzen2
      emacs
      fd
      firefox
      mpv
      pamixer
      pavucontrol
      ripgrep
      rustChannels.nightly.rust
      stow
      xfce.terminal
      xscreensaver
      xsel
      youtube-dl
    ];
  };
}
