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
    package = pkgs.swayfx.overrideAttrs (_: {
      passthru.providedSessions = ["sway"];
    });
    wrapperFeatures.gtk = true;
    wrapperFeatures.base = true;
    extraPackages = with pkgs; [
      kanshi
      mako  # Notifications
      bemenu wofi  # Menu launchers
      grim slurp  # Screenshot utils
      wl-clipboard cliphist  # Clipboard copy/paste
      waybar
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Electron Wayland support
  };
}
