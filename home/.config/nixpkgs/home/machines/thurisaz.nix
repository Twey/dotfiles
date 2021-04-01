{ ... }:
{
  imports = [ ../modules/base.nix ];
  programs.git.signing.key = "1B63E80AA5CA35C3";
  home.stateVersion = "20.09";
}
