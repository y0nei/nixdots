{ ... }:

{
  services.kanshi = {
    enable = true;
    profiles = {
      undocked.outputs = [{
        criteria = "eDP-1";
        status = "enable";
        mode = "1920x1080";
        position = "0,0";
      }];
      thinkpad-dock.outputs = [
        {
          criteria = "eDP-1";
          status = "disable";
        }
        {
          criteria = "DP-4";
          status = "enable";
          mode = "1920x1080@75Hz";
          position = "0,0";
        }
      ];
    };
  };
}
