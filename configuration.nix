# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./host-specific.nix
      <home-manager/nixos>
    ];


  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  documentation.dev.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  services = {
    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = false;

    # Smartcard
    pcscd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    # Printing
    printing.enable = true;
    avahi.enable = true;
    avahi.nssmdns4 = true;

    # Thumbnails
    tumbler.enable = true;

    # X11
    xserver = {
      enable = true;
      xkb = {
        variant = "";
        layout = "us";
      };
      dpi = 192;

      xautolock = {
        enable = true;
        locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
      };

      windowManager.i3 = {
        enable = true;
        #   extraPackages = with pkgs; [
        #     dmenu
        #     i3status
        #     i3lock
        #   ];
      };

      # desktopManager = {
      #   xterm.enable = false;

      #   xfce = {
      #     enable = true;
      #     noDesktop = true;
      #     enableXfwm = false;
      #   };
      # };

      # displayManager.defaultSession = "xfce+i3";
    };
  };

  security.rtkit.enable = true;

  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [ "/share/zsh" ];
    etc.hosts.mode = "0644";
  };

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mira = {
    isNormalUser = true;
    description = "miracoly";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.mira = import ./home.nix;
    backupFileExtension = "backup";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Docker
  virtualisation.docker.enable = true;

  environment.etc."bin/bash".source = "${pkgs.bash}/bin/bash";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    arandr
    firefox
    git
    man-pages
    man-pages-posix
    nixos-option
    pavucontrol
    vim
    xorg.xrandr
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8080 ];
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
