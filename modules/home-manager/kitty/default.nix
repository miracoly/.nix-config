_: {
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMonoNLNerdFont";
    font.size = 12;
    settings = import ./settings.nix;
    # theme = "Monokai Pro (Filter Machine)";
    keybindings = {
      # unmap conflicts with neovim
      "ctrl+shift+b" = "no_op";
      "ctrl+shift+f" = "no_op";
      "ctrl+shift+n" = "no_op";
      "ctrl+shift+w" = "no_op";
    };
  };
}
