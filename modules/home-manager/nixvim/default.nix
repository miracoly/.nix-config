{ config, lib, pkgs, nixvim, ... }:
{
  imports = [ nixvim.homeManagerModules.nixvim ];

  home.packages = with pkgs; [
    ripgrep
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;

    colorschemes.nightfox = {
      enable = true;
      flavor = "nordfox";
    };

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
      scrolloff = 4; # Number of screen lines to show around the cursor
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

              # navigate to prev/next location
              "<C-A-Left>" = "<C-o>";
              "<C-A-Right>" = "<C-i>";

              # navigate to left/right buffer
              "<A-j>" = ":bp<CR>";
              "<A-k>" = ":bn<CR>";

              # navigate to left/right tab
              "<A-Left>" = ":tabprevious<CR>";
              "<A-Right>" = ":tabnext<CR>";
              "<A-h>" = ":tabprevious<CR>";
              "<A-l>" = ":tabnext<CR>";

              # navigate to left/right window
              "<C-h>" = "<C-w>h";
              "<C-l>" = "<C-w>l";
              "<C-j>" = "<C-w>j";
              "<C-k>" = "<C-w>k";

              # resize with arrows
              "<C-Down>" = ":resize -2<CR>";
              "<C-Up>" = ":resize +2<CR>";
              "<C-Right>" = ":vertical resize +2<CR>";
              "<C-Left>" = ":vertical resize -2<CR>";

              # move current line up/down
              # M = Alt key
              "<C-S-Up>" = ":move-2<CR>";
              "<C-S-Down>" = ":move+<CR>";

              # neo-tree
              "<A-1>" = ":Neotree action=focus reveal toggle<CR>";

              # oversser
              "<F22>" = ":OverseerRestartLastAndOpen<CR>"; # S-F10
              "<F58>" = ":OverseerRun<CR>"; # A-F10
              "<A-4>" = ":OverseerToggle<CR>";

              # github copilot
              "<leader>c" = ":CopilotChatToggle<CR>";

              # lazygit
              "<C-S-k>" = ":LazyGit<CR>";

              # gitsigns
              "<leader>gr" = ":Gitsigns reset_hunk<CR>"; # reset hunk
              "<leader>gs" = ":Gitsigns preview_hunk<CR>"; # show hunk
              "<leader>gtb" = ":Gitsigns toggle_current_line_blame<CR>"; # toggle blame
              "<leader>gb" = ":Gitsigns blame_line<CR>"; # blame line
              "<F7>" = ":Gitsigns next_hunk<CR>"; # next hunk
              "<F19>" = ":Gitsigns prev_hunk<CR>"; # prev hunk
            };
        insert =
          lib.mapAttrsToList
            (key: action: {
              mode = "i";
              inherit action key;
            })
            {
              # better indenting
              "<S-TAB>" = "<C-d>";
            };
        visual =
          lib.mapAttrsToList
            (key: action: {
              mode = "v";
              inherit action key;
            })
            {
              # better indenting
              ">" = ">gv";
              "<" = "<gv";
              "<TAB>" = ">gv";
              "<S-TAB>" = "<gv";

              # move selected line / block of text in visual mode
              "K" = ":m '<-2<CR>gv=gv";
              "J" = ":m '>+1<CR>gv=gv";
            };
      in
      config.lib.nixvim.keymaps.mkKeymaps
        { options.silent = true; }
        (normal ++ insert ++ visual);

    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      overseer-nvim
    ];

    extraConfigLua = ''
      -- Overseer
      local overseer = require('overseer')

      overseer.setup({
        task_list = {
          -- Define default direction for the task list window
          direction = "bottom",  -- Opens the task list in a horizontal split
          min_height = 10,  -- Minimum height for the task list window
          max_height = 10,  -- Maximum height for the task list window
          default_detail = 1,
        },
      })

      vim.api.nvim_create_user_command("OverseerRestartLastAndOpen", function()
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.notify("No tasks found", vim.log.levels.WARN)
        else
          overseer.run_action(tasks[1], "restart")
          overseer.open({ enter = false })
        end
      end, {})

      local cmp = require'cmp'

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({'/', "?" }, {
        sources = {
          { name = 'buffer' }
        }
      })
      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
      })
    '';

    plugins = {
      autoclose = {
        enable = false;
      };

      bufferline = {
        enable = true;
      };

      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 20;
          };
          snippet = {
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
          formatting = { fields = [ "kind" "abbr" "menu" ]; };

          mapping = {
            "<C-Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<ESC>" = ''
              function ()
                cmp.mapping.close()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
              end
            '';
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          };

          sources = [
            { name = "git"; }
            { name = "nvim_lsp"; }
            { name = "emoji"; }
            {
              name = "buffer"; # text within current buffer
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              keywordLength = 3;
            }
            {
              name = "path"; # file system paths
              keywordLength = 3;
            }
            {
              name = "luasnip"; # snippets
              keywordLength = 3;
            }
          ];
        };
      };

      cmp-nvim-lua.enable = true;
      cmp-buffer.enable = true; # Enable suggestions for buffer in current file
      cmp-cmdline.enable = false; # Enable autocomplete for command line
      cmp-nvim-lsp.enable = true;
      # cmp-nvim-lua.enable = true;
      cmp_luasnip.enable = true; # Enable suggestions for code snippets
      cmp-path.enable = true; # Enable suggestions for file system paths
      cmp-zsh.enable = true;

      comment = {
        enable = true;

        settings = {
          opleader.line = "<C-/>";
          toggler.line = "<C-/>";
          post_hook = ''
            function(ctx)
              vim.api.nvim_command('normal! j')
            end
          '';
        };
      };

      copilot-chat = {
        enable = true;
      };

      copilot-vim = {
        enable = true;
      };

      dressing = {
        enable = true;
        settings = {
          select = {
            backend = [
              "telescope"
              # "fzf_lua"
              # "fzf"
              # "builtin"
              # "nui"
            ];
          };
          mappings = {
            i = {
              "<C-c>" = "Close";
              "<CR>" = "Confirm";
              "<Down>" = "HistoryNext";
              "<Up>" = "HistoryPrev";
            };
            n = {
              "<CR>" = "Confirm";
              "<Esc>" = "Close";
            };
          };
        };
      };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = " ▎";
            change.text = " ▎";
            delete.text = " 󰐊";
            topdelete.text = " 󰐊";
            changedelete.text = " 󰐊";
          };
        };
      };

      indent-blankline = {
        enable = true;
      };

      lazygit = {
        enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          bashls = {
            enable = true;
            settings = {
              telemetry = {
                enable = false;
              };
            };
          };
          clangd = {
            enable = true;
            settings = {
              telemetry = {
                enable = false;
              };
            };
          };
          eslint.enable = true;
          graphql.enable = true;
          hls = {
            enable = true;
            installGhc = true;
          };
          html.enable = true;
          jsonls.enable = true;
          nil_ls.enable = true;
          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          tailwindcss.enable = true;
          terraformls.enable = true;
          ts_ls.enable = true;
          volar.enable = true;
        };
        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<F14>" = "goto_prev";
            "<F2>" = "goto_next";
            "<F25>" = "open_float";
          };

          lspBuf = {
            "<C-b>" = "definition";
            # "<C-A-b>" = "references";
            "<C-S-b>" = "type_definition";
            gi = "implementation";
            "<C-q>" = "hover";
            "<C-p>" = "signature_help";
            "<A-CR>" = "code_action";
            "<F18>" = "rename";
          };

        };
      };

      lspkind = {
        enable = true;
        symbolMap = {
          Copilot = " ";
        };
        extraOptions = {
          maxwidth = 50;
          ellipsis_char = "...";
        };
      };

      lualine = {
        enable = true;
        settings = {
          sections = {
            lualine_x = [
              "diagnostics"

              # Show active language server
              {
                __unkeyed-1.__raw = ''
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

      luasnip = {
        enable = true;
      };

      neo-tree = {
        enable = true;

        closeIfLastWindow = true;
        window = {
          width = 30;
          autoExpandWidth = true;
        };
      };

      none-ls = {
        enable = true;
        settings = {
          onAttach = ''
            function(client, bufnr)
              -- Set the keymap for formatting
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-A-l>',
                '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })
            end
          '';
        };
        sources = {
          code_actions = {
            statix.enable = true;
            # gitsigns.enable = true;
          };
          diagnostics = {
            actionlint.enable = true;
            checkstyle.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            # pylint.enable = true;
          };
          formatting = {
            stylua.enable = true;
            shfmt.enable = true;
            nixpkgs_fmt.enable = true;
            # google_java_format.enable = false;
            # prettier = {
            # enable = true;
            # disableTsServerFormatter = true;
            # };
          };
          completion = {
            luasnip.enable = true;
            spell.enable = true;
          };
        };
      };

      telescope = {
        enable = true;

        keymaps = {
          # Find files using Telescope command-line sugar.
          "<C-S-n>" = "find_files";
          "<C-S-f>" = "live_grep";
          "<leader>b" = "buffers";
          # "<leader>fh" = "help_tags";
          "<leader>fd" = "diagnostics";

          # FZF like bindings
          # "<C-p>" = "git_files";
          "<C-e>" = "oldfiles";
          "<C-f>" = "current_buffer_fuzzy_find";

          # LSP
          "<C-A-b>" = "lsp_references";
        };

        settings.defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^.mypy_cache/"
            "^__pycache__/"
            "^output/"
            "^data/"
            "%.ipynb"
          ];
          set_env.COLORTERM = "truecolor";
        };

        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<F60>]]"; # Alt-F12
        };
      };

      treesitter = {
        enable = true;
        nixvimInjections = true;
        folding = true;
        settings = {
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-w>";
              node_incremental = "<C-w>";
              # scopeIncremental = "grc";
              node_decremental = "<C-S-w>";
            };
          };
        };
      };

      web-devicons = {
        enable = true;
      };
    };
  };
}
