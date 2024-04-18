{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      enableCryptodisk = true;
      device = "nodev";
      theme = pkgs.stdenv.mkDerivation {
        pname = "catppuccin-grub";
        version = "1.0";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "grub";
          rev = "803c5df";
          sha256 = "1kgcs7dl83iwfn6q18b8frikv159an9vpx2kwacn1w2s5faaid7x";
        };
        installPhase = "cp -r src/catppuccin-mocha-grub-theme $out";
      };
    };
  };
}
