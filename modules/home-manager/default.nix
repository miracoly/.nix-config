{ lib, pkgs, config, ... }:
{
  imports = [
    ./autorandr
    ./copyq
    ./i3
    ./i3status
    ./kitty
    ./nvim
    ./picom
    ./redshift
    ./rofi
    ./vscode
    ./zsh
  ];
}
