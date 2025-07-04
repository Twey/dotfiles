{ pkgs, lib, ... }:
{
  imports = [ home/modules/base.nix home/modules/picom.nix ];
  programs.git.signing.key = "1B63E80AA5CA35C3";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];
  home.packages = with pkgs; [
    chromium
    stack
    yt-dlp
    spotify
  ];
  home.stateVersion = "20.09";
  services.playerctld.enable = true;
}
