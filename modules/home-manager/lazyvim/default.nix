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

    extraPackages = with pkgs; [
      clang-tools
      cmake
      cmake-lint
      curl
      gdb
      fd
      fzf
      haskell-language-server
      helm-ls
      lazygit
      lldb
      lua-language-server
      marksman
      neocmakelsp
      nerdfonts
      nil
      markdownlint-cli2
      pyright
      ripgrep
      rubocop
      (ruby.withPackages (ps: [ps.solargraph]))
      ruff
      stylua
      tailwindcss-language-server
      vscode-js-debug
      vscode-langservers-extracted
      xclip
      vtsls
      yaml-language-server
    ];
  };
}
