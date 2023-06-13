{ pkgs, ... }:
{
  imports = [ home/modules/base.nix home/modules/picom.nix ];
  programs.git.signing.key = "68287F97D7901214DDF054ED749D0213D0C5A7CA";
  home.packages = with pkgs; [
    chromium
    stack
    youtube-dl
  ];
  home.stateVersion = "20.09";
}
