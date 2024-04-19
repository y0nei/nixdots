{ pkgs, ... }:

{
  programs = {
    xfconf.enable = true;  # Allow preference changes
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  services = {
    gvfs.enable = true;  # Mount, trash, and other functionalities
    tumbler.enable = true;  # Image thumbnails
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    wrapperFeatures.base = true;
    extraPackages = with pkgs; [
      kanshi
      mako  # Notifications
      bemenu wofi  # Menu launchers
      grim slurp  # Screenshot utils
      wl-clipboard cliphist  # Clipboard copy/paste
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
}
