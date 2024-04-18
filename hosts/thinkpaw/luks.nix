{ config, pkgs, ... }:

{
  boot.initrd.luks.devices = {
    luksroot = {
      device = "/dev/disk/by-uuid/04f05e03-f328-4202-b5c7-5863ac5d6a06";
      allowDiscards = true;
      preLVM = true;
    };
  };
}
