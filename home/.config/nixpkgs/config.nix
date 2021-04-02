{ pkgs }:
{
  allowUnfree = true;
  allowUnfreePredicate = pkg: builtins.elem (builtins.trace (pkgs.lib.getName pkg)) [
    "1password"
  ];
}

