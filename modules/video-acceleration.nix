{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {
      enableHybridCodec = true;
    };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  # Force intel-media-driver
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}
