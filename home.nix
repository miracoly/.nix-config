{ config, lib, pkgs, ... }:
let
  homedir = "/home/mira";
  secrets = import ./.secrets.nix;
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
      kubectl
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
      steam
      steam-run
      stella
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

  # copyQ
  services.copyq.enable = true;
  home.file.copyq.source = "${homedir}/.nix-config/config/copyq/copyq.conf";
  home.file.copyq.target = ".config/copyq/copyq.conf";
  home.file.copyq-commands.source = "${homedir}/.nix-config/config/copyq/copyq-commands.ini";
  home.file.copyq-commands.target = ".config/copyq/copyq-commands.ini";

  services.flameshot.enable = true;

  services.network-manager-applet.enable = true;

  # picom
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    activeOpacity = 0.95;
    inactiveOpacity = 0.9;
    menuOpacity = 0.9;
    opacityRules = [
      "100:name *= 'YouTube'"
      "100:name *= 'Prime Video'"
      "100:name *= 'Netflix'"
      "100:name *= 'Vimeo'"
      "100:name *= 'Coursera'"
      "100:name *= 'Huddle'"
      "100:name *= 'edX'"
      "100:name *= 'Pikuma'"
      "100:name *= 'Schneider Akademie'"
      "100:name *= 'A Cloud Guru'"
    ];

    fade = true;
    fadeSteps = [ 0.03 0.03 ];

    settings = {
      detect-client-opacity = true;
      detect-rounded-corners = true;
      detect-transient = true;
      focus-exclude = [
        "class_g = 'Cairo-clock'"
        "class_g = 'Peek'"
      ];
      inactive-opacity-override = false;
      log-level = "warn";
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      use-damage = true;
      blur = {
        method = "dual_kawase";
        size = 8;
        strenght = 1;
        background = true;
        kern = "3x3box";
        background-exclude = [
          "class_g = 'Peek'"
        ];
      };
    };

    shadow = true;
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    shadowOffsets = [ (-7) (-7) ];
    shadowOpacity = 0.6;

    wintypes = {
      tooltip = { fade = true; shadow = true; opacity = 0.9; focus = true; full-shadow = false; };
      dock = { shadow = false; clip-shadow-above = true; };
      dnd = { shadow = false; };
      popup_menu = { opacity = 0.9; };
      dropdown_menu = { opacity = 0.9; };
    };
  };

  # redshift
  services.redshift = {
    enable = true;
    provider = "geoclue2";
    settings.redshift = {
      adjustment-method = "randr";
      brightness-day = 1;
      brightness-night = 0.7;
      gamma = 1;
    };
    temperature = {
      day = 5500;
      night = 5000;
    };
    tray = true;
  };

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

  # i3
  xsession.windowManager.i3 = {
    enable = true;
    config =
      let
        keybindings = {
          mod = config.xsession.windowManager.i3.config.modifier;
          up = "k";
          down = "j";
          left = "h";
          right = "l";
        };
      in
      {
        bars = [
          {
            colors = {
              background = "#455559aa";
              statusline = "#FFF5F4";
              separator = "#8F736F";
            };
            extraConfig = ''
              separator_symbol " | "
              i3bar_command i3bar --transparency
            '';
            fonts = {
              names = [ "JetBrainsMonoNLNerdFont" ];
              size = 10.0;
            };
            statusCommand = "i3status";
          }
        ];
        colors.background = "#282420";
        floating.border = 0;
        fonts = {
          names = [ "JetBrainsMonoNLNerdFont" ];
          size = 10.0;
        };
        gaps.inner = 10;

        keybindings = with keybindings; lib.mkOptionDefault {
          "floating_modifier" = mod;
          "tiling_drag modifier" = "titlebar";

          # change focus
          "${mod}+${up}" = "focus up";
          "${mod}+${down}" = "focus down";
          "${mod}+${left}" = "focus left";
          "${mod}+${right}" = "focus right";

          # move focused window
          "${mod}+Shift+${up}" = "move up";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${right}" = "move right";

          # split
          "${mod}+v" = "split h";
          "${mod}+Shift+v" = "split v";

          # tiling / floating
          "${mod}+Shift+t" = "floating toggle";
          "${mod}+t" = "focus mode_toggle";

          # Applications
          "${mod}+Shift+d" = "exec rofi -show run -modi run";
          "${mod}+c" = "exec rofi -show calc -modi calc -no-show-match -no-sort";
          "${mod}+Shift+b" = "exec --no-startup-id rofi-bluetooth";
          "${mod}+Shift+m" = "exec rofi -show emoji -modi 'emoji:rofimoji --action=copy'";
          "${mod}+Shift+f" = "exec rofi -show filebrowser -modi filebrowser";
          "${mod}+Shift+s" = "exec --no-startup-id rofi-systemd";
          "${mod}+Shift+mod1+p" = "exec rofi -show p -modi p:'rofi-power-menu'";
          "${mod}+Shift+mod1+l" = "exec --no-startup-id i3lock-fancy";
          "${mod}+Shift+mod1+h" = "exec echo 'Xft.dpi: 152' | ${pkgs.xorg.xrdb}/bin/xrdb -merge";
          "${mod}+Shift+mod1+m" = "exec echo 'Xft.dpi: 200' | ${pkgs.xorg.xrdb}/bin/xrdb -merge";
          "Print" = "exec flameshot gui";

          # Volume
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5% && $refresh_i3status";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5% && $refresh_i3status";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";

          # Brightness
          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl --min-val=1 -q set 5%-";
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl -q set 5%+";
        };

        menu = "rofi -show drun";

        modes = with keybindings; lib.mkOptionDefault {
          resize = {
            "${up}" = "resize shrink height 100 px or 10 ppt";
            "${down}" = "resize grow height 100 px or 10 ppt";
            "${left}" = "resize shrink width 100 px or 10 ppt";
            "${right}" = "resize grow width 100 px or 10 ppt";
            "${mod}+r" = "mode default";
          };
        };

        modifier = "Mod4";

        startup = [
          { command = "blueman-applet"; notification = false; }
          { command = "copyq"; always = true; notification = false; }
          # TODO - image does not exist in setup
          { command = "feh --bg-tile ~/Pictures/wallpaper/8k/surreal-6645614.jpg &"; always = true; notification = false; }
          { command = "flameshot"; notification = false; }
          { command = "pa-applet"; notification = false; }
          { command = "picom -b"; always = true; notification = false; }
          { command = "setxkbmap -layout 'de,de' -variant 'us,qwerty' -option 'grp:win_space_toggle'"; notification = false; }
          # { command = "echo 'Xft.dpi: 152' | ${pkgs.xorg.xrdb}/bin/xrdb -merge"; always = true; notification = false; }
        ];
        terminal = "kitty";
        window = {
          border = 0;
          hideEdgeBorders = "both";
          titlebar = false;
        };
      };
  };
}
