{ lib, pkgs, ... }:
let
  homedir = "/home/mira";
  secrets = import ./.secrets.nix;
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7e7c39ea35c5cdd002cd4588b03a3fb9ece6fad9.tar.gz") { };
in
{

  imports = [ ./modules ];
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

    packages = with pkgs;
      let
        ca65-symbls-to-nl = pkgs.callPackage ./derivations/ca65-symbls-to-nl.nix { };
        codecrafters-cli = pkgs.callPackage ./derivations/codecrafters-cli.nix { };
        inherit (unstable.nodePackages) pnpm;
        inherit (unstable) zed-editor;
      in
      [
        _1password-gui
        appimage-run
        audacious
        audacity
        asciidoctor
        azure-cli
        bitwarden
        bitwarden-cli
        brightnessctl
        bruno
        ca65-symbls-to-nl
        cabal2nix
        calibre
        cc65
        codecrafters-cli
        dasm
        dbeaver-bin
        discord
        dotty
        exercism
        fceux
        fluxcd
        gauge
        gcc
        gdb
        gh
        ghc
        gimp
        gitlint
        gnumake
        google-chrome
        haskellPackages.cabal-fmt
        haskellPackages.cabal-install
        haskellPackages.hlint
        haskellPackages.hoogle
        haskellPackages.ormolu
        haskellPackages.stack
        haskellPackages.stylish-haskell
        haskellPackages.yesod-bin
        haskell-language-server
        i3lock-fancy-rapid
        inkscape
        inotify-tools
        insomnia
        (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.clion [ "github-copilot" ])
        (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea-ultimate [ "github-copilot" ])
        jetbrains.pycharm-professional
        jq
        k9s
        kate
        keepassxc
        kind
        kubectl
        (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-secrets ]; })
        libnotify
        maven
        minikube
        mysql80
        nerdfonts
        nil
        nix-index
        nixpkgs-fmt
        node2nix
        nodejs_20
        nodePackages.npm-check-updates
        nodePackages.yarn
        nomacs
        openssl
        p7zip
        pa_applet
        pandoc
        pciutils
        peek
        pinentry-curses
        pinta
        pipenv
        pnpm
        pulseaudio
        python311
        racket
        rofi-bluetooth
        rofi-file-browser
        rofi-power-menu
        rofi-systemd
        rofimoji
        sbt
        slack
        sops
        steam
        steam-run
        stella
        telepresence2
        terraform
        texlive.combined.scheme-full
        unzip
        wget
        xclip
        yubikey-manager
        yubikey-manager-qt
        yubikey-personalization
        yubikey-personalization-gui
        yubico-piv-tool
        yubioath-flutter
        zed-editor
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
      # Applications
      yubikey-rofi.source = "${homedir}/.nix-config/config/applications/yubikey-rofi.desktop";
      yubikey-rofi.target = ".local/share/applications/yubikey-rofi.desktop";

      # Other .dotfiles
      ideavim.source = "${homedir}/.nix-config/config/ideavim/.ideavimrc";
      ideavim.target = ".ideavimrc";

      # Latex Dnd Templage
      dnd-latex-template.source = pkgs.fetchFromGitHub {
        owner = "rpgtex";
        repo = "DND-5e-LaTeX-Template";
        rev = "v0.8.0";
        sha256 = "sha256-jSYC0iduKGoUaYI1jrH0cakC45AMug9UodERqsvwVxw=";
      };
      dnd-latex-template.target = "texmf/tex/latex/dnd";

      # Azure CLI Autocomplete
      azure-cli-completion.source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion";
        sha256 = "sha256-xCV7HpYI5SupUZVo5j0cIOB4vP2Ux6H/0+qUzN81FwU=";
      };
      azure-cli-completion.target = ".azure-cli/az.completion";
    };

    activation = {
      wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${homedir}/Pictures/wallpaper" ]; then
          ${pkgs.git}/bin/git clone https://miracoly@github.com/miracoly/wallpaper.git ${homedir}/Pictures/wallpaper
        else
          ${pkgs.git}/bin/git -C ${homedir}/Pictures/wallpaper pull
        fi
      '';
    };
  };

  accounts.email.accounts = with secrets.email; {
    miracoly = with miracoly; {
      inherit address;
      folders = {
        drafts = "Drafts";
        inbox = "Inbox";
        sent = "Sent";
        trash = "Trash";
      };
      imap = {
        host = "posteo.de";
        port = 993;
        tls.enable = true;
      };
      primary = true;
      inherit realName;
      signature = { };
      smtp = {
        host = "posteo.de";
        port = 587;
        tls.enable = true;
      };
      thunderbird.enable = true;
      userName = address;
    };
    kb = with kb; {
      inherit address;
      folders = {
        drafts = "Drafts";
        inbox = "Inbox";
        sent = "Sent";
        trash = "Trash";
      };
      imap = {
        host = "imap.gmail.com";
        port = 993;
        tls.enable = true;
      };
      inherit realName;
      signature = { };
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.enable = true;
      };
      thunderbird.enable = true;
      userName = address;
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
      pinentryPackage = pkgs.pinentry-curses;
    };

    network-manager-applet.enable = true;

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 5 3";
      xautolock.enable = true;
    };
  };

  programs = {

    feh.enable = true;
    firefox.enable = true;

    gpg.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    htop.enable = true;

    java.enable = true;
    java.package = pkgs.jdk21;

    # git
    git = {
      enable = true;
      userName = "miracoly";
      userEmail = "68049792+miracoly@users.noreply.github.com";
      ignores = [
        "*~"
        "*.swp"
        "*.out"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = "store";
      };
    };

    thunderbird = {
      enable = true;

      profiles.miracoly = {
        isDefault = true;
      };
    };

    zathura.enable = true;
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
