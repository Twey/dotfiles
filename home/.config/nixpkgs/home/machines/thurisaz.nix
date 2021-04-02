{ pkgs, ... }:
{
  imports = [ ../modules/base.nix ];
  programs.git.signing.key = "1B63E80AA5CA35C3";
  home.packages = with pkgs; [
    chromium
    stack
    youtube-dl
  ];
}
