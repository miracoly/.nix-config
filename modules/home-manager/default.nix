{ lib, pkgs, config, ... }:
{
  imports = [
    ./autorandr
    ./i3status
    ./kitty
    ./nvim
    ./rofi
    ./vscode
    ./zsh
  ];
}
