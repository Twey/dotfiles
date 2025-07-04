{ lib, pkgs, ... }:
{
  imports = [ home/modules/base.nix home/modules/wayland.nix ];
  programs.git.signing.key = "57F8A27F72DA6AA222C69C7B526D950913F6A0B9";
  home.packages = with pkgs; [
    chromium
    stack
    yt-dlp
  ];
  home.stateVersion = "24.05";

  services.hyprpaper = let
    trees = "${~/.wallpapers/watercolor-trees.jpeg}";
  in {
    enable = true;
    settings = {
      splash = false;
      preload = [ trees ];
      wallpaper = [ ", ${trees}" ];
    };
  };
}
