{ pkgs, ... }:

let
  sway-kiosk = pkgs.writeText "sway-kiosk" ''
    # avoid wait before login
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

    # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    input "type:touchpad" {
      tap enabled
    }

    xwayland disable
  '';
in
{
  environment.systemPackages = with pkgs; [
    greetd.greetd
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${sway-kiosk}";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    sway
    bash
  '';
}
