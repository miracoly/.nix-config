{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  # Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_6_11;
    kernelModules = ["kvm-intel"];

    extraModulePackages = [];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Setup keyfile
    initrd = {
      availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];

      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      # Enable swap on luks
      luks.devices = {
        "luks-eda0301b-844e-4dae-98c0-1bb2bd8fc293" = {
          device = "/dev/disk/by-uuid/eda0301b-844e-4dae-98c0-1bb2bd8fc293";
          keyFile = "/crypto_keyfile.bin";
        };
        "luks-4b34f8c7-c90c-41a1-8b4b-f9cc0a533377".device = "/dev/disk/by-uuid/4b34f8c7-c90c-41a1-8b4b-f9cc0a533377";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a2efba35-6ab5-498b-aca9-9086ccddd2c6";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E9FA-6A00";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/6bff4513-a2f2-47bb-88c9-8de78a3d5eea";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp165s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Host specific
  services = {
    xserver.videoDrivers = ["modesetting"];
    blueman.enable = true;
    libinput.enable = true;
  };

  hardware = {
    graphics.extraPackages = with pkgs; [intel-media-driver];
    bluetooth.enable = true;
  };

  # Bootloader.
  networking.hostName = "miras-xps-93xx"; # Define your hostname.
}
