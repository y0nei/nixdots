{ config, pkgs, ... }:

{
  boot.initrd.luks.devices = {
    luksroot = {
      device = "/dev/disk/by-uuid/41825851-de26-468b-8e67-a140de4d35e1";
      allowDiscards = true;
      preLVM = true;
    };
  };
}
