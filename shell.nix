{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    stow
    rsync
    bashInteractive
  ];
}
