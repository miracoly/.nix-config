{ lib, pkgs, config, ... }:
{
  imports = [
    ./autorandr
    ./copyq
    ./i3
    ./i3status
    ./kitty
    ./nvim
    ./redshift
    ./rofi
    ./vscode
    ./zsh
  ];
}
