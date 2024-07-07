{ config, lib, pkgs, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-24.05";
    # When using a different channel you can use `ref = "nixos-<version>"` to set it here
  });
in
{
  imports = [ nixvim.homeManagerModules.nixvim ];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;

    colorschemes.gruvbox.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    clipboard = {
      register = "unnamedplus";
      providers.xclip.enable = true;
    };

    opts = {
      updatetime = 100; # Faster completion

      # Line numbers
      relativenumber = true; # Relative line numbers
      number = true; # Display the absolute line number of the current line
      hidden = true; # Keep closed buffer open in the background
      mouse = "a"; # Enable mouse control
      mousemodel = "extend"; # Mouse right-click extends the current selection
      splitbelow = true; # A new window is put below the current one
      splitright = true; # A new window is put right of the current one

      swapfile = false; # Disable the swap file
      modeline = true; # Tags such as 'vim:ft=sh'
      modelines = 100; # Sets the type of modelines
      undofile = true; # Automatically save and restore undo history
      incsearch = true; # Incremental search: show match for partly typed search command
      inccommand = "split"; # Search and replace: preview changes in quickfix list
      ignorecase = true; # When the search query is lower-case, match both lower and upper-case
      #   patterns
      smartcase = true; # Override the 'ignorecase' option if the search pattern contains upper
      #   case characters
      scrolloff = 8; # Number of screen lines to show around the cursor
      cursorline = false; # Highlight the screen line of the cursor
      cursorcolumn = false; # Highlight the screen column of the cursor
      signcolumn = "yes"; # Whether to show the signcolumn
      colorcolumn = "81"; # Columns to highlight
      laststatus = 3; # When to use a status line for the last window
      fileencoding = "utf-8"; # File-content encoding for the current buffer
      termguicolors = true; # Enables 24-bit RGB color in the |TUI|
      spell = false; # Highlight spelling mistakes (local to window)
      wrap = false; # Prevent text from wrapping

      # Tab options
      tabstop = 2; # Number of spaces a <Tab> in the text stands for (local to buffer)
      softtabstop = 2; # Number of spaces a <Tab> counts for while performing editing operations
      shiftwidth = 2; # Number of spaces used for each step of (auto)indent (local to buffer)
      expandtab = true; # Expand <Tab> to spaces in Insert mode (local to buffer)
      autoindent = true; # Do clever autoindenting

      textwidth = 0; # Maximum width of text that is being inserted.  A longer line will be
      #   broken after white space to get this width.

      # Folding
      foldlevel = 99; # Folds with a level higher than this number will be closed

      virtualedit = "block"; # Allow the cursor to move where there is no text in Visual mode
    };

    keymaps =
      let
        normal =
          lib.mapAttrsToList
            (key: action: {
              mode = "n";
              inherit action key;
            })
            {
              "<Space>" = "<NOP>";

              # Esc to clear search results
              "<esc>" = ":noh<CR>";

              # fix Y behaviour
              Y = "y$";

              # back and fourth between the two most recent files
              # "<C-c>" = ":b#<CR>";

              # close by Ctrl+F4
              "<F28>" = ":bd<CR>";

              # save by Space+w or Ctrl+s
              "<leader>w" = ":w<CR>";
              "<C-s>" = ":w<CR>";

              # navigate to left/right window
              "<C-h>" = "<C-w>h";
              "<C>l" = "<C-w>l";

              # resize with arrows
              "<C-Up>" = ":resize -2<CR>";
              "<C-Down>" = ":resize +2<CR>";
              "<C-Left>" = ":vertical resize +2<CR>";
              "<C-Right>" = ":vertical resize -2<CR>";

              # move current line up/down
              # M = Alt key
              "<C-S-Up>" = ":move-2<CR>";
              "<C-S-Down>" = ":move+<CR>";
            };
        #        visual =
        #          lib.mapAttrsToList
        #            (key: action: {
        #              mode = "v";
        #              inherit action key;
        #            })
        #            {
        #              # better indenting
        #              ">" = ">gv";
        #              "<" = "<gv";
        #              "<TAB>" = ">gv";
        #              "<S-TAB>" = "<gv";
        #
        #              # move selected line / block of text in visual mode
        #              "K" = ":m '<-2<CR>gv=gv";
        #              "J" = ":m '>+1<CR>gv=gv";
        #            };
      in
      config.nixvim.helpers.keymaps.mkKeymaps
        { options.silent = true; }
        (normal); # ++ visual);

    plugins = {
      bufferline = {
        enable = true;
      };

      cmp = {
        enable = true;
        #        mapping = {
        #          "<CR>" = "cmp.mapping.confirm({ select = true })";
        #          "<Tab>" = {
        #            action = ''
        #              function(fallback)
        #                if cmp.visible() then
        #                  cmp.select_next_item()
        #                elseif luasnip.expandable() then
        #                  luasnip.expand()
        #                elseif luasnip.expand_or_jumpable() then
        #                  luasnip.expand_or_jump()
        #                elseif check_backspace() then
        #                  fallback()
        #                else
        #                  fallback()
        #                end
        #              end
        #            '';
        #            modes = [ "i" "s" ];
        #          };
        #        };
      };

      cmp-nvim-lua.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-zsh.enable = true;

      lsp = {
        enable = true;
        servers = {
          eslint.enable = true;
          nil-ls.enable = true;
          lua-ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          tsserver.enable = true;
          volar.enable = true;
        };
        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };
      };

      lualine = {
        enable = true;
        sections = {
          lualine_x = [
            "diagnostics"

            # Show active language server
            {
              name.__raw = ''
                function()
                    local msg = ""
                    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                    local clients = vim.lsp.get_active_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end
              '';
              icon = "";
              color.fg = "#ffffff";
            }
            "encoding"
            "fileformat"
            "filetype"
          ];
        };
      };
    };
  };
}
