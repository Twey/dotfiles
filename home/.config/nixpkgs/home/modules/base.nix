{ config, pkgs, ... }:
let
  enableMusl = rustChannel: rustChannel // {
    rust = rustChannel.rust.override (o: {
      targets    = o.targets or [] ++ ["x86_64-unknown-linux-musl"];
      extensions = o.extensions or [] ++ ["clippy-preview"];
      targetExtensions = o.targetExtensions or [] ++ ["clippy-preview"];
    });
  };
in rec {
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
      extraConfig = {
        pull.ff = "only";
        merge.conflictstyle = "diff3";
      };
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
  };

  home = rec {
    username = "twey";
    homeDirectory = "/home/${username}";

    keyboard = null;

    sessionVariables.MOZ_USE_XINPUT2 = "1";
    sessionVariables.EDITOR = ''emacsclient -a \"\" -c'';

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
      manpages
      mpv
      mupdf
      nox
      pamixer
      pavucontrol
      plover.dev
      ripgrep
      (enableMusl rustChannels.nightly).rust
      stow
      weechat
      xfce.terminal
      xscreensaver
      xsel
      youtube-dl
      zip
    ];
  };
}
