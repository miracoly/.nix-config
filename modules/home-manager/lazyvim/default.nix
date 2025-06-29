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

    extraLuaPackages = ps: [ps.magick];

    extraPackages = with pkgs; [
      bash-language-server
      clang-tools
      cmake
      cmake-lint
      curl
      gdb
      gopls
      fd
      fzf
      haskell-language-server
      helm-ls
      imagemagick
      lazygit
      lldb
      lua-language-server
      marksman
      neocmakelsp
      nerd-fonts.jetbrains-mono
      nil
      markdownlint-cli2
      pyright
      ripgrep
      rubocop
      (ruby.withPackages (ps: [ps.solargraph]))
      ruff
      shfmt
      shellcheck
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
