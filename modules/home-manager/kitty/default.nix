{ lib, config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMonoNLNerdFont";
    font.size = 12;
    settings = import ./settings.nix;
    # theme = "Monokai Pro (Filter Machine)";
    keybindings = {
      "ctrl+shift+n" = "no_op";
      "ctrl+shift+f" = "no_op";
    };
  };
}
