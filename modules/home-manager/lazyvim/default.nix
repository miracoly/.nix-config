{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.file.".config/nvim" = {
    source = ./config;
  };

  # Global markdownlint defaults, used as the base config for every markdown
  # file. Any project-local .markdownlint.* file still overrides these.
  home.file.".config/markdownlint/config.yaml".text = ''
    # Disable MD013 (line-length) everywhere by default.
    MD013: false
  '';
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython3 = false;
    withRuby = false;

    extraLuaPackages = ps: [ps.magick];

    extraPackages = with pkgs; [
      bash-language-server
      buf
      clang-tools
      pkgs-unstable.claude-code
      clippy # Rust cargo-clippy
      cmake
      cmake-format
      cmake-lint
      curl
      delve
      gdb
      gopls
      fd
      fzf
      hadolint
      haskell-language-server
      helm-ls
      imagemagick
      lazygit
      lldb
      lua5_1
      luarocks
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
      rust-analyzer
      rustfmt
      shfmt
      shellcheck
      sqlfluff
      statix
      stylua
      tailwindcss-language-server
      tree-sitter
      vscode-js-debug
      vscode-langservers-extracted
      xclip
      vtsls
      yaml-language-server
    ];
  };
}
