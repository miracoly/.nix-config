{ config, pkgs, ... }: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mira";
  home.homeDirectory = "/home/mira";

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
  ];

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

  # zsh
  programs.zsh.enable = true;

  services.copyq.enable = true;
  services.flameshot.enable = true;

  # picom
  services.picom = {
    enable = true;

    activeOpacity = 0.95;
    inactiveOpacity = 0.90;
    
    fade = true;
    fadeSteps = [ 0.03 0.03 ];

    shadow = true;
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    shadowOffsets = [ (-7) (-7) ];
  }; 

  # i3
  xsession.windowManager.i3 = {
    enable = true;
    config = {
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
      startup = [
        { command = "blueman-applet"; notification = false; }
        # TODO - image does not exist in setup
        { command = "feh --bg-tile ~/Pictures/wallpaper/8k/sun-mountains-7680.jpg &"; notification = false; }
        { command = "flameshot"; notification = false; }
        { command = "picom -b"; notification = false; }
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
