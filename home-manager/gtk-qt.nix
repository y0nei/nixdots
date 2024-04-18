{ pkgs, ... }:

{
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Breeze_Snow";
      package = pkgs.libsForQt5.breeze-qt5;
    };
    iconTheme = {
      name = "Vimix-dark";
      # BUG: Nix package has icon scailing issues on thunar.
      #package = pkgs.vimix-icon-theme;
    };
    theme = {
      name = "Nordic-bluish-accent";
      package = pkgs.nordic;
    };
  };
}
