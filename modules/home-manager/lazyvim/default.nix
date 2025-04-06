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
      codelldb = pkgs.stdenv.mkDerivation {
        name = "codelldb";
        buildCommand = ''
          mkdir -p $out/bin
          ln -s "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb" $out/bin/codelldb
        '';
      };
      lsp = [
        clang-tools
        haskell-language-server
        lua-language-server
        nil
      ];
    in
      [
        codelldb
        curl
        fd
        fzf
        lazygit
        lldb
        nerdfonts
        ripgrep
        stylua
        xclip
      ]
      ++ lsp;
  };
}
