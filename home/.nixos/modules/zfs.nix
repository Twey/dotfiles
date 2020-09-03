{ ... }:
{
  boot.supportedFilesystems = ["zfs"];
  services.zfs.trim.enable = true;
}
