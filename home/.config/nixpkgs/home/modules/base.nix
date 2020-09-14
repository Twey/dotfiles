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
      signing.signByDefault = true;
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

    keyboard = null;

    packages = with pkgs; [
      bc
      conky
      direnv
      dzen2
      emacs
      fd
      firefox
      git-secret
      gnupg
      mpv
      pamixer
      pavucontrol
      ripgrep
      rustChannels.nightly.rust
      stow
      weechat
      xfce.terminal
      xscreensaver
      xsel
      youtube-dl
    ];
  };
}
