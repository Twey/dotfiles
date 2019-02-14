{ config, pkgs, ... }:
{ services.printing =
  { enable = true;
    drivers = [ pkgs.foomatic-filters pkgs.gutenprint pkgs.poppler_utils ]; };
  environment.systemPackages = [ pkgs.poppler_utils ];
  services.journald.rateLimitBurst = 0; }
