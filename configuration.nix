# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
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
    dbus.packages = [pkgs.gcr];

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
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

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

  security = {
    rtkit.enable = true;
    pki.certificates = [
      ''
        data-hub.local
        ===
        -----BEGIN CERTIFICATE-----
        MIIDLzCCAhegAwIBAgIUCdWc5EPM8eGURZVvLyX6v7h0GxgwDQYJKoZIhvcNAQEL
        BQAwDjEMMAoGA1UEAwwDdWRwMB4XDTI1MDUwODA5NTQzOFoXDTM1MDUwNjA5NTQz
        OFowDjEMMAoGA1UEAwwDdWRwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
        AQEAy/dhMKlzewitj2rDcgwkRcy+4EfQhFq+IgaLP3+tmHdB0xRTxRjS2Tdeur5d
        ksFl20Vs81aLgdfR+BxC8XYDvgYAg3V8O/o1JRWnlCI+02M7KWf4jORCkBAET7AF
        DVK5b12UXj+PbIyELR1bGH4/oIte0NjLZP19ddnL2Pir6fp2ErQneS0xV0bHDBUR
        fYeiIInhVUHx3IR/6089NopH5Htbu0REgQF+AeJiRL3RO7BguG050s98yFe32Vzi
        BPJ/MH8krf1drY4NLxxf1LRGkZ5lJJ2/wSuxFYMiW+BqyTU30WvUlE5cjE3o1mnV
        QxUtL8HESbKmM0kesur97cqC9QIDAQABo4GEMIGBMB0GA1UdDgQWBBSofzNCRZcM
        KkSMr6XMF7kBKJP2SzAfBgNVHSMEGDAWgBSofzNCRZcMKkSMr6XMF7kBKJP2SzAP
        BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwICBDAeBgNVHR4EFzAVoBMwEYIP
        LmRhdGEtaHViLmxvY2FsMA0GCSqGSIb3DQEBCwUAA4IBAQAZVT22oZUYdFw8QJ8e
        ttfyVtLMZ5iXzje99l12Fp4vrqKHKDkKyzuD0N11ompvXI0lyGRyRFNOqqloBUNt
        hwWwcuFlzZo7tHb4WV5xj8BI65Dla9WYrAuPW4S9UIeJIClz8K+gTEIh3PYRFQ6j
        biRsjeW7oAZ9hmZPyzZT1NMthw1H0o0dX2965MfehwwuduSyMcV1VnMOqV5KtrZd
        oI9inWuzLSmOg9qhm+U7MilNHgtaRn0XaR34KvYS7JTJxESQqu933oqXCcVratXB
        yxgZsTnDbsEKdAQFefWQetZcx3HEKUogm0PH5ZuBgCJ2t2baumaLKCPsqXMYsSo6
        TSkY
        -----END CERTIFICATE-----
      ''
      ''
        udp.teuto.dev
        ===
        -----BEGIN CERTIFICATE-----
        MIIDLjCCAhagAwIBAgIURnRqolTma6+fsmTEiqsMRfJb250wDQYJKoZIhvcNAQEL
        BQAwDjEMMAoGA1UEAwwDdWRwMB4XDTI1MDUwODA5NTY1N1oXDTM1MDUwNjA5NTY1
        N1owDjEMMAoGA1UEAwwDdWRwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
        AQEAyKNHcqL2MejuGL8e56tDlCDSN2sVmCrFtoym5ZOvjlhpUhDuufTERbnjUAhD
        KI2gfYLS+8DuSQtkBctJoBLBOkGwkBIrPoBCvqrbsYfrOhzLHBUAJBR2+c4XwwhO
        bbvdF8/dLIV53jKz9p7R1O9bwnf9WHFxzhpU5ENSp9znHM/3DvTqx1O3y0H4/nqh
        HYTDDh7hJm1BDl2Nyt8JoW66PU6DQ1PkpGYhlXhPJAxgS3o2g9Fb+MgaTcDD1rt8
        QXQkFTKgV4CQkHx0Z7TtFXwSWI7FMGx+oL7PNmOguauLABA3ZNqgjHMb2fRKq8fu
        SFR+DQiFN8XD/l++nW3QJdl15wIDAQABo4GDMIGAMB0GA1UdDgQWBBTJ3UvKrfPR
        Al7JubyrUcbQsgWxcjAfBgNVHSMEGDAWgBTJ3UvKrfPRAl7JubyrUcbQsgWxcjAP
        BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwICBDAdBgNVHR4EFjAUoBIwEIIO
        LnVkcC50ZXV0by5kZXYwDQYJKoZIhvcNAQELBQADggEBAF1r5NynYht+cDVaUWaj
        5K3rUD52dlmHM/YyKyGN+OefN7eOS0EC8eKuhUAVO4JSSAnuSfp+qDPbty/qZSkt
        0ndIX+lwZ7BDqVzq0YhTEnlH5cVc2LWH3DMsfAGu2s4PBRqkZKhvC+03CJDoRmBi
        qOpGuSGMe6oN/mxacBy503ln9zHYn//IxMj4o122xcgdPWBgY6DKoPy28nwqyYCC
        euGHabxcIsJUspVSIlhg2B4/mMVthmfROjEyQk73s4+5Zkmejk/vNUGtUa7IOj2I
        YaRRTGlGd9FKokLzWxJfGCpih/FCXcF9Fc+aw9cvM+LYOso3PrUFyN09YiZEGhQa
        q9s=
        -----END CERTIFICATE-----
      ''
    ];
  };

  environment = {
    shells = with pkgs; [zsh];
    pathsToLink = ["/share/zsh"];
    etc.hosts.mode = "0644";
  };

  programs = {
    i3lock = {
      enable = true;
      package = pkgs.i3lock-fancy-rapid;
    };
    zsh.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mira = {
    isNormalUser = true;
    description = "miracoly";
    extraGroups = ["networkmanager" "wheel" "docker" "input" "dialout"];
    shell = pkgs.zsh;
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
    gitFull
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
    allowedTCPPorts = [8080];
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = ["mira"];

      substituters = [
        "https://cache.nixos.org"
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
