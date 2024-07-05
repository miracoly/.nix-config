{ config, lib, pkgs, ... }:
let
  homedir = "/home/mira";
  secrets = import ./.secrets.nix;
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2741b4b489b55df32afac57bc4bfd220e8bf617e.tar.gz") {};
in
{

  imports = [ ./modules ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mira";
  home.homeDirectory = "${homedir}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  home.sessionPath = [
    "${homedir}/.local/share/coursier/bin"
  ];

  home.packages = with pkgs;
    let
      ca65-symbls-to-nl = pkgs.callPackage ./derivations/ca65-symbls-to-nl.nix { };
      codecrafters-cli = pkgs.callPackage ./derivations/codecrafters-cli.nix { };
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
      i3lock-fancy
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
      (wrapHelm kubernetes-helm {plugins = [kubernetes-helmPlugins.helm-secrets];})
      libnotify
      maven
      minikube
      mysql80
      nerdfonts
      nix-index
      nixpkgs-fmt
      node2nix
      nodejs_20
      nodePackages.npm-check-updates
      unstable.nodePackages.pnpm
      nodePackages.yarn
      nomacs
      p7zip
      pa_applet
      pandoc
      pciutils
      peek
      pinta
      pipenv
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
      xclip
      yubikey-manager
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

  home.sessionVariables = {
    FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT = 1;
    DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 2;
    ROFI_SYSTEMD_TERM = "kitty";
  };

  accounts.email.accounts = with secrets.email; {
    miracoly = with miracoly; {
      address = address;
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
      realName = realName;
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
      address = address;
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
      realName = realName;
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

  # Applications
  home.file.yubikey-rofi.source = "${homedir}/.nix-config/config/applications/yubikey-rofi.desktop";
  home.file.yubikey-rofi.target = ".local/share/applications/yubikey-rofi.desktop";

  # Other .dotfiles
  home.file.ideavim.source = "${homedir}/.nix-config/config/ideavim/.ideavimrc";
  home.file.ideavim.target = ".ideavimrc";

  home.activation = {
    wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${homedir}/Pictures/wallpaper" ]; then
        ${pkgs.git}/bin/git clone https://miracoly@github.com/miracoly/wallpaper.git ${homedir}/Pictures/wallpaper
      else
        ${pkgs.git}/bin/git -C ${homedir}/Pictures/wallpaper pull
      fi
    '';
  };

  # Latex Dnd Templage
  home.file.dnd-latex-template.source = pkgs.fetchFromGitHub {
    owner = "rpgtex";
    repo = "DND-5e-LaTeX-Template";
    rev = "v0.8.0";
    sha256 = "sha256-jSYC0iduKGoUaYI1jrH0cakC45AMug9UodERqsvwVxw=";
  };
  home.file.dnd-latex-template.target = "texmf/tex/latex/dnd";

  # Azure CLI Autocomplete
  home.file.azure-cli-completion.source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion";
    sha256 = "sha256-xCV7HpYI5SupUZVo5j0cIOB4vP2Ux6H/0+qUzN81FwU=";
  };
  home.file.azure-cli-completion.target = ".azure-cli/az.completion";

  # autorandr
  services.autorandr.enable = false;

  services.dunst.enable = true;

  programs.feh.enable = true;
  programs.firefox.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.htop.enable = true;

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;

  # git
  programs.git = {
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

  programs.thunderbird = {
    enable = true;

    profiles.miracoly = with secrets.email.miracoly; {
      isDefault = true;
    };
  };

  programs.zathura.enable = true;

  services.flameshot.enable = true;
  services.network-manager-applet.enable = true;

  services.screen-locker = {
    enable = true;
    lockCmd = "/usr/bin/env i3lock";
    xautolock.enable = true;
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
