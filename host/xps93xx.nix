{ pkgs, ... }:
{
  # Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_6_10;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Setup keyfile
    initrd = {
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      # Enable swap on luks
      luks.devices."luks-eda0301b-844e-4dae-98c0-1bb2bd8fc293".device = "/dev/disk/by-uuid/eda0301b-844e-4dae-98c0-1bb2bd8fc293";
      luks.devices."luks-eda0301b-844e-4dae-98c0-1bb2bd8fc293".keyFile = "/crypto_keyfile.bin";
    };

  };

  # Host specific
  services = {
    xserver.videoDrivers = [ "modesetting" ];
    blueman.enable = true;
    libinput.enable = true;
  };

  hardware = {
    opengl.extraPackages = with pkgs; [ intel-media-driver ];
    bluetooth.enable = true;
  };

  # Bootloader.
  networking.hostName = "miras-xps-93xx"; # Define your hostname.
}
