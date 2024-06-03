{ config, pkgs, ... }:
{
  # Host specific
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];
  services.libinput.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-eda0301b-844e-4dae-98c0-1bb2bd8fc293".device = "/dev/disk/by-uuid/eda0301b-844e-4dae-98c0-1bb2bd8fc293";
  boot.initrd.luks.devices."luks-eda0301b-844e-4dae-98c0-1bb2bd8fc293".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "miras-xps-93xx"; # Define your hostname.
}
