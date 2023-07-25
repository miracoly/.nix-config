{ config, lib, pkgs, ... }: 
  let
    HOME = "/home/mira";
  in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mira";
  home.homeDirectory = "${HOME}";

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
    neovim
    nerdfonts
    peek
    pulseaudio
    rofi-bluetooth
    rofi-power-menu
    rofimoji
  ];

  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_SCALE_FACTOR = 2;
    GDK_SCALE = 2;
    GDK_DPI_SCALE = 0.5;
  };

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
    ];
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  # i3status
  programs.i3status.enable = true;

  # kitty
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMonoNLNerdFont";
    font.size = 24;
    theme = "Earthsong";
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

  # zsh
  programs.zsh.enable = true;

  # copyQ
  services.copyq.enable = true;
  home.file.copyq.source = "${HOME}/.nix-config/config/copyq/copyq.conf";
  home.file.copyq.target = ".config/copyq/copyq.conf";
  home.file.copyq-commands.source = "${HOME}/.nix-config/config/copyq/copyq-commands.ini";
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
      tooltip = { fade = true; shadow = true; opacity = 0.75; focus = true; full-shadow = false; };
      dock = { shadow = false; clip-shadow-above = true; };
      dnd = { shadow = false; };
      popup_menu = { opacity = 0.8; };
      dropdown_menu = { opacity = 0.8; };
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
    in {
      bars = [
        {
          statusCommand = "i3status";
          colors = {
            background = "#282420";
            statusline = "#e5c6a8";
          };
          extraConfig = ''
            separator_symbol " | "
            i3bar_command i3bar --transparency
          '';
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
        { command = "feh --bg-tile ~/Pictures/wallpaper/8k/sun-mountains-7680.jpg &"; notification = false; }
        { command = "flameshot"; notification = false; }
        { command = "picom -b"; always = true; notification = false; }
        { command = "setxkbmap -layout us,de -variant 'basic,qwerty' -option 'grp:win_space_toggle'"; notification = false; }
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
