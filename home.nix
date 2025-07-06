{
  pkgs,
  pkgs-unstable,
  pkgs-telepresence,
  dnd-latex-template,
  purescript-overlay,
  wallpaper,
  ...
}: let
  homedir = "/home/mira";
in {
  imports = [./modules];
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "mira";
    homeDirectory = "${homedir}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";

    sessionPath = [
      "${homedir}/.local/bin"
      "${homedir}/.local/share/coursier/bin"
    ];

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 48;
    };

    packages = with pkgs; let
      ca65-symbls-to-nl = pkgs.callPackage ./derivations/ca65-symbls-to-nl.nix {};
      sasm = pkgs.callPackage ./derivations/sasm.nix {};
    in [
      _1password-gui
      alejandra
      # anki
      anki-bin
      appimage-run
      arduino-cli
      arduino-core
      arduino-ide
      audacious
      audacity
      asciidoctor-with-extensions
      azure-cli
      bat
      bitwarden
      bitwarden-cli
      bootdev-cli
      brightnessctl
      bruno
      ca65-symbls-to-nl
      cabal2nix
      cachix
      calibre
      cc65
      chromium
      cmake
      pkgs-unstable.codecrafters-cli
      ctop
      dasm
      dbeaver-bin
      discord
      dotty
      entr
      exercism
      fceux
      fluxcd
      gauge
      gcc
      gdb
      gdbgui
      gh
      ghc
      gimp
      gitlint
      ghex
      gnome-disk-utility
      gnumake
      go
      google-chrome
      google-java-format
      gradle
      graphviz
      haskellPackages.cabal-fmt
      haskellPackages.cabal-install
      haskellPackages.hlint
      haskellPackages.hoogle
      haskellPackages.ormolu
      haskellPackages.stack
      haskellPackages.stylish-haskell
      haskellPackages.yesod-bin
      haskell-language-server
      ihp-new
      inkscape
      inotify-tools
      insomnia
      jetbrains.clion
      jetbrains.goland
      jetbrains.idea-ultimate
      jq
      k9s
      kdePackages.kate
      keepassxc
      kind
      kubectl
      (wrapHelm kubernetes-helm {plugins = [kubernetes-helmPlugins.helm-secrets];})
      libnotify
      liquibase
      maven
      mermaid-cli
      minikube
      mob
      mysql80
      nasm
      ncdu
      nerd-fonts.jetbrains-mono
      nerd-fonts."m+"
      nerd-fonts.noto
      nil
      nix-index
      nixd
      nixpkgs-fmt
      node2nix
      nodejs_22
      nodePackages.npm-check-updates
      nodePackages.yarn
      nomacs
      obs-studio
      obsidian
      openssl
      p7zip
      pa_applet
      pandoc
      pciutils
      peek
      pinentry-curses
      pinta
      pipenv
      pnpm_10
      prusa-slicer
      pulseaudio
      purescript-overlay.packages.${pkgs.system}.purs
      purescript-overlay.packages.${pkgs.system}.spago
      python311
      racket
      rofi-bluetooth
      rofi-file-browser
      rofi-power-menu
      rofi-systemd
      rofimoji
      sasm
      sbt
      slack
      sops
      steam-run
      stella
      pkgs-telepresence.telepresence2
      go-task
      terraform
      texlive.combined.scheme-full
      unzip
      wget
      xclip
      yubikey-manager
      yubikey-personalization
      yubikey-personalization-gui
      yubico-piv-tool
      yubioath-flutter
      # zed-editor
      zip
      zlib
      zoom-us
      # needed for cypress
      # gtk2
      gtk3
      nss
      xorg.libXScrnSaver
      xorg.libXdamage
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXi
      xorg.libXext
      xorg.libXfixes
      xorg.libXcursor
      xorg.libXrender
      xorg.libXrandr
      pkgs-unstable.zed-editor
    ];

    sessionVariables = {
      FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT = 1;
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = 2;
      ROFI_SYSTEMD_TERM = "kitty";
      KUBECONFIG = "${homedir}/.kube/config:${homedir}/.kube/udp-staging.config";
      GPG_TTY = "$(tty)";
    };

    file = {
      # Azure CLI Autocomplete
      azure-cli-completion.source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion";
        sha256 = "sha256-xCV7HpYI5SupUZVo5j0cIOB4vP2Ux6H/0+qUzN81FwU=";
      };
      azure-cli-completion.target = ".azure-cli/az.completion";

      # Latex Dnd Templage
      dnd-latex-template.source = dnd-latex-template;
      dnd-latex-template.target = "texmf/tex/latex/dnd";

      # .gdbinit
      ".gdbinit".text = ''
        python
        import sys
        sys.path.insert(0, "${pkgs.gcc-unwrapped.lib}/share/gcc-${pkgs.gcc-unwrapped.version}/python")
        from libstdcxx.v6.printers import register_libstdcxx_printers
        register_libstdcxx_printers(gdb.current_objfile())
        end
      '';

      # Other .dotfiles
      ideavim.source = ./config/ideavim/.ideavimrc;
      ideavim.target = ".ideavimrc";

      # Wallpaper
      wallpaper.source = wallpaper;
      wallpaper.target = "Pictures/wallpaper";

      # Applications
      yubikey-rofi.source = ./config/applications/yubikey-rofi.desktop;
      yubikey-rofi.target = ".local/share/applications/yubikey-rofi.desktop";
    };
  };

  services = {
    autorandr.enable = false;

    dunst.enable = true;

    flameshot.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      extraConfig = ''
        allow-loopback-pinentry
      '';
      pinentry.package = pkgs.pinentry-curses;
    };

    network-manager-applet.enable = true;

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 5 3";
      xautolock.enable = false;
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    feh.enable = true;
    firefox.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    gpg = {
      enable = true;
      publicKeys = [
        {source = ./config/gpg/public-key.asc;}
      ];
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    htop.enable = true;

    java.enable = true;

    # git
    git = {
      enable = true;
      userName = "miracoly";
      userEmail = "68049792+miracoly@users.noreply.github.com";
      aliases = {
        br = "!b=$(git branch --show-current) && git checkout --detach && git commit --amend --no-verify -m \"require $b\" && git checkout -b";
      };
      ignores = [
        "*~"
        "*.swp"
        "*.out"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = "store";
        pull.rebase = "true";
      };
    };

    thunderbird = {
      enable = true;

      profiles.miracoly = {
        isDefault = true;
      };
    };

    zathura = {
      enable = true;
      extraConfig = ''
        set selection-clipboard clipboard
      '';
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
