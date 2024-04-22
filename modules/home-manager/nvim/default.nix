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

      plugins =
        let
          vs-tasks = pkgs.vimUtils.buildVimPlugin {
            name = "vs-tasks";
            src = pkgs.fetchFromGitHub {
              owner = "EthanJWright";
              repo = "vs-tasks.nvim";
              rev = "5a5d9e5959c8abadb6f979e88a1366c7ac51b876";
              sha256 = "sha256-OvHBOJfe8EO6zJSmptVUtByX+rKdJ4cucX6l5bM05xg=";
            };
          };
        in with pkgs.vimPlugins; [
        cmp_luasnip
        cmp-nvim-lsp

        {
          plugin = comment-nvim;
          config = toLua ''require("Comment").setup()'';
        }

        friendly-snippets

        haskell-tools-nvim

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

        nvim-dap

        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./config/plugin/lsp.lua;
        }

        nvim-web-devicons
        plenary-nvim
        popup-nvim

        {
          plugin = telescope-nvim;
          config = toLuaFile ./config/plugin/telescope.lua;
        }

        telescope-ui-select-nvim
        {
          plugin = toggleterm-nvim;
          config = toLuaFile ./config/plugin/toggleterm.lua;
        }
        
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = toLuaFile ./config/plugin/treesitter.lua;
        }

        vs-tasks
      ];

      extraPackages = with pkgs; [
        fd
        haskellPackages.fast-tags
        haskellPackages.haskell-debug-adapter
        haskellPackages.hoogle
        haskell-language-server
        lua-language-server
        millet
        nodePackages.eslint
        nodePackages.prettier
        nodePackages.typescript-language-server
        nodePackages.volar
        ripgrep
        stylua
        tree-sitter
        vscode-langservers-extracted
        xclip
      ];
    };
}
