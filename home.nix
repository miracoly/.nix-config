{ config, lib, pkgs, ... }: 
  let
    homedir = "/home/mira";
  in {
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

  home.packages = with pkgs; [
    bitwarden
    bitwarden-cli
    gimp
    google-chrome
    jq
    kate
    libnotify
    neovim
    nerdfonts
    nodejs_18
    nodePackages.yarn
    peek
    pulseaudio
    rofi-bluetooth
    rofi-file-browser
    rofi-power-menu
    rofi-systemd
    rofimoji
  ];

  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    ROFI_SYSTEMD_TERM = "kitty";
  };

  # autorandr
  programs.autorandr = {
    enable = true;
    profiles = {
      mobile = {
        fingerprint = {
          eDP-1 = "00ffffffffffff004d10ad14000000002a1c0104a51d11780ede50a3544c99260f5054000000010101010101010101010101010101014dd000a0f0703e803020350026a510000018a4a600a0f0703e803020350026a510000018000000fe00305239394b804c513133334431000000000002410328011200000b010a20200041";
        };
        config = {
         eDP-1 = { 
           enable = true;
           crtc = 0;
           mode = "3840x2160";
           position = "0x0";
           primary = true;
           rate = "60.00";
         };
        };
        hooks = {
          postswitch = ''
            #!/usr/bin/env bash
            ${pkgs.i3}/bin/i3-msg restart
            echo "Xft.dpi: 160" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
            ${pkgs.feh}/bin/feh --bg-center ~/Pictures/wallpaper/8k/surreal-6645614.jpg &
            ${pkgs.libnotify}/bin/notify-send "autorandr" "profile mobile loaded" 
          '';
        };
      };
      homeoffice = {
        fingerprint = {
          eDP-1 = "00ffffffffffff004d10ad14000000002a1c0104a51d11780ede50a3544c99260f5054000000010101010101010101010101010101014dd000a0f0703e803020350026a510000018a4a600a0f0703e803020350026a510000018000000fe00305239394b804c513133334431000000000002410328011200000b010a20200041";
          DP-1 = "00ffffffffffff0009d15479455400001d1f0104b54628783bdd75ae4f44ad270b5054a56b80818081c08100a9c0b300d1c0010101014dd000a0f0703e8030203500c48f2100001a000000ff004b374d30313932383031390a20000000fd00283c87873c010a202020202020000000fc0042656e5120455733323830550a0150020334f15161605f5e5d101f222120051404131203012309070783010000e200cf67030c0020003878e305c301e606050162623204740030f2705a80b0588a00c48f2100001e565e00a0a0a029502f203500c48f2100001a00000000000000000000000000000000000000000000000000000000000000000000000000000062";
          DP-2 = "00ffffffffffff0009d1547945540000301f0104b54628783bdd75ae4f44ad270b5054a56b80818081c08100a9c0b300d1c0010101014dd000a0f0703e8030203500c48f2100001a000000ff0058424d30303739353031390a20000000fd00283c87873c010a202020202020000000fc0042656e5120455733323830550a0124020334f15161605f5e5d101f222120051404131203012309070783010000e200cf67030c0020003878e305c301e606050162623204740030f2705a80b0588a00c48f2100001e565e00a0a0a029502f203500c48f2100001a00000000000000000000000000000000000000000000000000000000000000000000000000000062";
        };
        config = {
          eDP-1.enable = false; 
          DP-2 = { 
            enable = true;
            crtc = 0;
            mode = "3840x2160";
            position = "0x0";
            primary = true;
            rate = "60.00";
          };
          DP-1 = { 
            enable = true;
            crtc = 0;
            mode = "3840x2160";
            position = "3840x0";
            primary = true;
            rate = "60.00";
          };
        };
        hooks = {
          postswitch = ''
            #!/usr/bin/env bash
            ${pkgs.i3}/bin/i3-msg restart
            echo "Xft.dpi: 160" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
            ${pkgs.feh}/bin/feh --bg-tile ~/Pictures/wallpaper/8k/surreal-6645614.jpg &
            ${pkgs.libnotify}/bin/notify-send "autorandr" "profile homeoffice loaded" 
          '';
        };
      };
    };
  };
  services.autorandr.enable = false;

  services.dunst.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.feh.enable = true;
  programs.firefox.enable = true;

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

  # i3status
  programs.i3status = {
    enable = true;
    general = {
      output_format = "i3bar";
      colors = true;
      color_good = "#82DAB4";
      color_degraded = "#FFD598";
      color_bad = "#FFA987";
      interval = 5;
    };
    modules = {
      ipv6 = {
        position = 0;
      };
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "W: (%quality at %essid) %ip";
          format_down = "W: down";
        };
      };
      "ethernet _first_" = {
        position = 2;
        settings = {
          format_up = "E: %ip (%speed)";
          format_down = "E: down";
        };
      };
      "battery all" = {
        position = 3;
        settings = {
          format = "BAT %status %percentage %remaining";
          status_chr = "chg";
          status_bat =  "dis";
          status_full = "full";
          integer_battery_capacity = true;
        };
      };
      "disk /" = {
        position = 4;
        settings = {
          format = "DISK %used / %total";
          prefix_type = "custom";
          low_threshold = 10;
        };
      };
      "cpu_temperature 0" = {
        position = 5;
        settings = {
          format = "T: %degrees °C";
          max_threshold = 42;
          format_above_threshold = "HOT T: %degrees°C";
        }; 
      };
      cpu_usage = {
        position = 6;
        settings = {
          format = "CPU %usage";
          max_threshold = 75;
        };
      };
      memory = {
        position = 7;
        settings = {
          format = "MEM %used / %total";
          threshold_degraded = "1G";
          format_degraded = "MEM < %available";
        };
      };
      "volume master" = {
        position = 8;
        settings = {
          format = "VOL %volume";
          format_muted = "VOL muted";
          device = "pulse";
        };
      };
      "tztime local" = {
        position = 9;
        settings = {
          format = "%d.%m.%Y - %H:%M:%S";
        };
      };
    };
  };

  # kitty
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMonoNLNerdFont";
    font.size = 12;
    settings = import ./home/kitty/theme.nix;
  };

  # rofi
  programs.rofi = {
    enable = true;
    font = "JetBrainsMonoNLNerdFont 24";
    plugins = with pkgs; [
      rofi-calc
      rofi-power-menu
      rofimoji
    ];
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./config/vim/vimrc;
    plugins = with pkgs.vimPlugins; [
      coc-nvim
      haskell-vim
      jsonc-vim
      lightline-vim
      markdown-preview-nvim
      vim-colorschemes
      vim-plug
      vim-polyglot
    ];
  };

  # zsh
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      source ".p10k.zsh";
    '';
    history.extended = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
        "azure"
        "stack"
      ];
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } 
      ];
    };
  };
  home.file.p10k.source = "${homedir}/.nix-config/config/p10k/p10k.zsh";
  home.file.p10k.target = ".p10k.zsh";

  # copyQ
  services.copyq.enable = true;
  home.file.copyq.source = "${homedir}/.nix-config/config/copyq/copyq.conf";
  home.file.copyq.target = ".config/copyq/copyq.conf";
  home.file.copyq-commands.source = "${homedir}/.nix-config/config/copyq/copyq-commands.ini";
  home.file.copyq-commands.target = ".config/copyq/copyq-commands.ini";

  services.flameshot.enable = true;

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
      tooltip = { fade = true; shadow = true; opacity = 0.6; focus = true; full-shadow = false; };
      dock = { shadow = false; clip-shadow-above = true; };
      dnd = { shadow = false; };
      popup_menu = { opacity = 0.6; };
      dropdown_menu = { opacity = 0.6; };
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
    in {
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
        "Print" = "exec flameshot gui";

        # Volume
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5% && $refresh_i3status";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5% && $refresh_i3status";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";

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
        { command = "copyq"; notification = false; }
        # TODO - image does not exist in setup
        { command = "feh --bg-tile ~/Pictures/wallpaper/8k/surreal-6645614.jpg &"; notification = false; }
        { command = "flameshot"; notification = false; }
        { command = "picom -b"; always = true; notification = false; }
        { command = "setxkbmap -layout us,de -variant 'basic,qwerty' -option 'grp:win_space_toggle'"; notification = false; }
        { command = "echo 'Xft.dpi: 160' | ${pkgs.xorg.xrdb}/bin/xrdb -merge"; always = true; notification = false; }
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
