{ pkgs, ... }:

{ environment.systemPackages = with pkgs;
  [ zsh
    emacs
    firefox
    ecryptfs
    ntfs3g
    most
    mtools ];
  virtualisation.docker.enable = true; }
