{ config, lib, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./luks.nix
  ];

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

  users.users.yonei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

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

  # Because sudo is bloated.
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "yonei" ];
      keepEnv = true;
      persist = true;
    }];
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
    blueberry
    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL

    (calibre.override (old: {
      # FIX: https://github.com/NixOS/nixpkgs/issues/305577
      python3Packages = old.python3Packages // {
        mechanize = python311Packages.mechanize.overridePythonAttrs (old: {
          doCheck = false;
        });
      };
    }))

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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;
  services.openssh.enable = true;

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  services.throttled.enable = true;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 75;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      # Docking
      DEVICES_TO_DISABLE_ON_DOCK="wifi";
      DEVICES_TO_ENABLE_ON_UNDOCK="wifi";

      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth";
    };
  };
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
