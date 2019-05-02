{
  allowUnfree = true;
  packageOverrides = super: let self = super.pkgs; in
  {
    agda-env = self.haskell.packages.ghc844.ghcWithPackages
    (hpkgs: with hpkgs;
     [ Agda ]);
  };
}
