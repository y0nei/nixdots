{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./luks.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader = {
#    efi = {
#       canTouchEfiVariables = true;  # Remove if in VM
#    };
    grub = {
       enable = true;
       efiInstallAsRemovable = true;  # Only for VM's
       efiSupport = true;
       enableCryptodisk = true;
       device = "nodev";
    };
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "yonei" ];
      keepEnv = true;
      persist = true;
    }];
  };

  users.users.yonei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    # Wrapper to replace sudo with doas. The -e flag with sudo wont work.
    (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
    neovim
    wget
    git
    alacritty  # terminal emulator
    grim  # Screenshot utility
    slurp  # Screenshot utility
    wl-clipboard  # Clipboard copy/paste utility
    mako  # Notification system from swaywm
    bemenu  # dmenu like wayland menu
    wofi  # rofi but wayland
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # TODO: Setup kanshi (https://nixos.wiki/wiki/Sway#Systemd_services)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  security.polkit.enable = true;
  services.openssh.enable = true;

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  system.stateVersion = "23.11";
}
