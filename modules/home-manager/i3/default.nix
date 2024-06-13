{ lib, pkgs, ... }:
{
  xsession.windowManager.i3 = {
    enable = true;
    config =
      let
        keybindings = {
          mod = "Mod4";
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

        modifier = keybindings.mod;

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
