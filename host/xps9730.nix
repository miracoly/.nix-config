{ pkgs, ... }:

{
  # Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_6_10;

    #  set a custom kernel parameter to 'thunderbolt.host_reset=false
    kernelParams = [ "thunderbolt.host_reset=false" ];

    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      # Setup keyfile
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      # Enable swap on luks
      luks.devices."luks-d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff".device = "/dev/disk/by-uuid/d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff";
      luks.devices."luks-d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff".keyFile = "/crypto_keyfile.bin";
    };
  };

  networking.hostName = "miras-xps-9730"; # Define your hostname.

  services = {
    blueman.enable = true;
    libinput.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    opengl.extraPackages = with pkgs; [ intel-media-driver ];
  };
}
