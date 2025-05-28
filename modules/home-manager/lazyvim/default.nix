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
        helm-ls
        lua-language-server
        marksman
        nil
        pyright
        ruff
        tailwindcss-language-server
        vscode-langservers-extracted
        vtsls
        yaml-language-server
      ];
    in
      [
        curl
        gdb
        fd
        fzf
        lazygit
        lldb
        nerdfonts
        markdownlint-cli2
        ripgrep
        stylua
        vscode-js-debug
        xclip
      ]
      ++ lsp;
  };
}
