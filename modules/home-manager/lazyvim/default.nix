{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./config;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; let
      lsp = [
        lua-language-server
        nil
      ];
    in
      [
        curl
        fd
        fzf
        lazygit
        nerdfonts
        ripgrep
        stylua
        xclip
      ]
      ++ lsp;
  };
}
