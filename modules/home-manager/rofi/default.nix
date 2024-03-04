{ lib, config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    font = "JetBrainsMonoNLNerdFont 24";
    theme = "Monokai";
    plugins = with pkgs; [
      rofi-calc
      rofi-power-menu
      rofimoji
    ];
  };
}
