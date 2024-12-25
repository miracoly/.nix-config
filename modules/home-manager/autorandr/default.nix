{
  pkgs,
  lib,
  ...
}: {
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
            echo "Xft.dpi: 250" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
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
            echo "Xft.dpi: 152" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
            ${pkgs.feh}/bin/feh --bg-tile ~/Pictures/wallpaper/8k/surreal-6645614.jpg &
            ${pkgs.libnotify}/bin/notify-send "autorandr" "profile homeoffice loaded"
          '';
        };
      };
    };
  };
}
