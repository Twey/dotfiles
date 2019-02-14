{ config, ... }:
{
  boot.initrd.luks.devices =
  [ { name          = "uruz";
      device        = "/dev/disk/by-uuid/eb1f73dd-2557-4c99-8346-b7068317e897";
      preLVM        = true;
      allowDiscards = true; } ];

  fileSystems."/" =
    { device = "/dev/mapper/uruz-root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0A7F-DB82";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/mapper/uruz-home";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/mapper/uruz-swap"; }
    ];
}
