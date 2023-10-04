{ config, pkgs, ... }:

{
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff".device = "/dev/disk/by-uuid/d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff";
  boot.initrd.luks.devices."luks-d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "miras-xps-9730"; # Define your hostname.
  
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.xserver.libinput.enable = true;

  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];
}
