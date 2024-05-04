{ lib, config, pkgs, ... }:
{
  imports = [
    ./kitty
    ./nvim
    ./rofi
    ./vscode
  ];
}
