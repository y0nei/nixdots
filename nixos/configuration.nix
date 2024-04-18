{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./luks.nix
    inputs.home-manager.nixosModules.home-manager
  ];

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
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.yonei = import ../home.nix;
    # Fix home-manager complaining about unfree packages
    useGlobalPkgs = true;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    wireless.iwd.enable = true;
    networkmanager.wifi.backend = "iwd";
  };

  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pl";

  # Needed for calibre
  services.udisks2.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

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
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    home-manager
    gcc git wget lm_sensors htop
    doas-sudo-shim
    eza bat
    networkmanagerapplet
    fastfetch
    zsh starship
    ffmpeg-full mpv
    xdg-utils
    alacritty
    pavucontrol
    librewolf
    telegram-desktop
    keepassxc
    p7zip mate.engrampa
    libsForQt5.kdenlive
    calibre
    blueberry

    ## Unfree
    # https://discourse.nixos.org/t/partly-overriding-a-desktop-entry/20743/2
    # HACK: Partially fix blurry Obsidian caused by fractional display scaling.
    # Using this instead of xdg.desktopEntries because the latter no worky for me :((
    (obsidian.overrideAttrs (e: rec {
      desktopItem = e.desktopItem.override (d: {
        exec = "env OBSIDIAN_USE_WAYLAND=1 ${d.exec} -enable-features=UseOzonePlatform -ozone-platform=wayland";
      });
      installPhase = builtins.replaceStrings [ "${e.desktopItem}" ] [ "${desktopItem}" ] e.installPhase;
    }))
  ];

  # Whitelist some unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Thunar
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;  # Mount, trash, and other functionalities
  services.tumbler.enable = true;  # Image thumbnails

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    wrapperFeatures.base = true;
    extraPackages = with pkgs; [
      kanshi
      bemenu wofi  # Menu launchers
      grim slurp  # Screenshot utils
      wl-clipboard cliphist  # Clipboard copy/paste
      mako  # Notifications
      ((waybar.overrideAttrs (_: {
        patches = [
          # FIX: Sway workspaces (https://github.com/Alexays/Waybar/issues/3009)
          (pkgs.fetchpatch {
            url = "https://github.com/Alexays/Waybar/commit/2ffd9a94a505a2e7e933ea8303f9cf2af33c35fe.patch";
            hash = "sha256-u87t6zzslk1mzSfi4HQ6zDPFr7qMfsvymTy3HBxVTJQ=";
          })
        ];
      # FIX: Waybar wants Wireplumber 0.4 but unstable has 0.5
      })).override { wireplumberSupport = false; })
    ];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {
        enableHybridCodec = true;
    };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  security.polkit.enable = true;
  services.openssh.enable = true;

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    # Higher defaults since my two batteries are summed up as one percentage.
    percentageAction = 5;
    percentageCritical = 7;
    percentageLow = 15;
  };

  system.stateVersion = "23.11";
}
