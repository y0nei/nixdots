{ config, pkgs, ... }:

{
  boot.initrd.luks.devices = {
    luksroot = {
      device = "/dev/disk/by-uuid/5e0af01c-4b5e-4d4c-a507-d68500f21e02";
      allowDiscards = true;
      preLVM = true;
    };
  };
}
