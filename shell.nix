{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    stow
    rsync
    gnupg
    bashInteractive
  ];
}
