{ lib, config, pkgs, ... }:
{
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./config/init.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = comment-nvim;
        config = toLua ''require("Comment").setup()'';
      }
      {
        plugin = monokai-pro-nvim;
        config = toLua ''
          require("monokai-pro").setup({
            filter = "machine"
          })
          vim.cmd("colorscheme monokai-pro")
        '';
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
      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./config/plugin/lsp.lua;
      }
      nvim-web-devicons
    ];

    extraPackages = with pkgs; [
      lua-language-server
      rnix-lsp
      xclip
    ];
  };
}
