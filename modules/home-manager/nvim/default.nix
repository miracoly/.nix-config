{ lib, config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    extraLuaConfig = lib.fileContents ./config/init.lua;
  };

  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
