{
    packageOverrides = super: let self = super.pkgs; in
    {
        agda-env = self.haskell.packages.ghc863Binary.ghcWithPackages
        (hpkgs: with hpkgs;
         [ Agda ]);
    }
}
