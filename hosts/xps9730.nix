{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_11;

    #  set a custom kernel parameter to 'thunderbolt.host_reset=false
    kernelParams = ["thunderbolt.host_reset=false"];
    kernelModules = ["kvm-intel"];

    extraModulePackages = [];

    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [];

      # Setup keyfile
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      # Enable swap on luks
      luks.devices = {
        "luks-145399d7-ae3b-4782-9478-1975dcb4d10a".device = "/dev/disk/by-uuid/145399d7-ae3b-4782-9478-1975dcb4d10a";
        "luks-d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff" = {
          device = "/dev/disk/by-uuid/d32204ca-bfa7-4f5c-99a7-8cf46dc8d5ff";
          keyFile = "/crypto_keyfile.bin";
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5be07160-a621-4915-a186-756026f2d993";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/CA5D-DC05";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/01b71c3e-d128-49d7-99da-c8eefd704075";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.hostName = "miras-xps-9730"; # Define your hostname.

  services = {
    blueman.enable = true;
    libinput.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    graphics.extraPackages = with pkgs; [intel-media-driver];
  };
}
