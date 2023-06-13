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
        init.defaultBranch = "main";
        delta.enable = true;
        pull.ff = "only";
        merge.conflictstyle = "diff3";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  services = {
    lorri.enable = true;

    random-background = {
      enable = true;
      imageDirectory = "%h/.wallpapers";
    };

    xscreensaver.enable = true;

    dunst.enable = true;
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
      man-pages
      mpv
      mupdf
      nox
      pamixer
      pavucontrol
      plover.dev
      python3
      ripgrep
      (rust-bin.nightly.latest.default.override {
        extensions = ["rust-src"];
        targets = ["x86_64-unknown-linux-musl"];
      })
      stow
      weechat
      xfce.xfce4-terminal
      xscreensaver
      xsel
      zip
    ];
  };
}
