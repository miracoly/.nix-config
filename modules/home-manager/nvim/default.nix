{ lib, config, pkgs, ... }:
{
  programs.neovim =
    let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
    {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = ''
        ${builtins.readFile ./config/init.lua}
        ${builtins.readFile ./config/keymaps.lua}
      '';

      plugins = with pkgs.vimPlugins; [
        cmp_luasnip
        cmp-nvim-lsp

        {
          plugin = comment-nvim;
          config = toLua ''require("Comment").setup()'';
        }

        friendly-snippets

        {
          plugin = haskell-tools-nvim;
          config = toLuaFile ./config/plugin/haskell-tools.lua;
        }

        {
          plugin = lualine-nvim;
          config = toLua ''
            require('lualine').setup({
              options = {
                theme = 'monokai-pro'
              }
            })
          '';
        }

        luasnip

        {
          plugin = monokai-pro-nvim;
          config = toLua ''
            require("monokai-pro").setup({
              filter = "machine"
            })
            vim.cmd("colorscheme monokai-pro")
          '';
        }

        neo-tree-nvim

        neodev-nvim

        {
          plugin = none-ls-nvim;
          config = toLuaFile ./config/plugin/none-ls.lua;
        }

        nui-nvim

        {
          plugin = nvim-cmp;
          config = toLuaFile ./config/plugin/cmp.lua;
        }

        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./config/plugin/lsp.lua;
        }

        nvim-web-devicons
        plenary-nvim

        {
          plugin = telescope-nvim;
          config = toLuaFile ./config/plugin/telescope.lua;
        }

        telescope-ui-select-nvim

        {
          plugin = nvim-treesitter.withAllGrammars;
          config = toLuaFile ./config/plugin/treesitter.lua;
        }
      ];

      extraPackages = with pkgs; [
        fd
        haskellPackages.haskell-language-server
        lua-language-server
        nodePackages.prettier
        nodePackages.typescript-language-server
        nodePackages.volar
        ripgrep
        rnix-lsp
        stylua
        tree-sitter
        vscode-langservers-extracted
        xclip
      ];
    };
}
