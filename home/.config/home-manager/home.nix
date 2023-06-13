{ pkgs, ... }:
{
  imports = [ home/modules/base.nix home/modules/picom.nix ];
  programs.git.signing.key = "68C05A40E7836DD7349685A653E4F0A1BCD8286D";
  home.packages = with pkgs; [
    chromium
    stack
    youtube-dl
  ];
  home.stateVersion = "20.09";
}
