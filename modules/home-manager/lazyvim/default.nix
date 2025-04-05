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
        clang-tools
        haskell-language-server
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
