{
  config,
  lib,
  pkgs,
  nixvim,
  ...
}: {
  imports = [nixvim.homeManagerModules.nixvim];

  home.packages = with pkgs; [
    ripgrep
    zsh
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
      have_nerd_fonts = true;
    };

    clipboard = {
      register = "unnamedplus";
      providers.xclip.enable = true;
    };

    opts = {
      updatetime = 250; # Faster completion
      timeoutlen = 300; # Faster completion

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
      scrolloff = 9; # Number of screen lines to show around the cursor
      cursorline = true; # Highlight the screen line of the cursor
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

      showmode = false; # Don't show the mode, since it's already in the status line
      breakindent = true; # Indent wrapped lines

      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };

      shell = "zsh";
    };

    keymaps = let
      _normal =
        lib.mapAttrsToList
        (key: action: {
          mode = "n";
          inherit action key;
        })
        {
          "<Space>" = "<NOP>";

          # Esc to clear search results
          "<Esc>" = ":noh<CR>";

          # fix Y behaviour
          Y = "y$";

          # back and fourth between the two most recent files
          # "<C-c>" = ":b#<CR>";

          # save by Space+w or Ctrl+s
          "<Enter>" = ":w<CR>";
          "<C-s>" = ":w<CR>";

          # resize with arrows
          "<C-Down>" = ":resize -2<CR>";
          "<C-Up>" = ":resize +2<CR>";
          "<C-Right>" = ":vertical resize +2<CR>";
          "<C-Left>" = ":vertical resize -2<CR>";

          # neo-tree
          "<A-1>" = ":Neotree action=focus reveal toggle<CR>";

          # oversser
          "<F22>" = ":OverseerRestartLastAndOpen<CR>"; # S-F10
          "<F58>" = ":OverseerRun<CR>"; # A-F10
          "<A-4>" = ":OverseerToggle<CR>";

          # lazygit
          "<C-S-k>" = ":LazyGit<CR>";
        };
      normal =
        lib.pipe
        {
          general = [
            {
              key = "<leader>wq";
              action = ":qa!<CR>";
              options = {
                desc = "Force [Q]uit";
              };
            }
            {
              key = "<leader>tt";
              action = ":99ToggleTerm direction=float name=\"Main Terminal\"<CR>";
              options = {
                desc = "[T]oggle floating [T]erminal";
              };
            }
          ];
          buffer = [
            {
              key = "<A-k>";
              action = ":bn<CR>";
            }
            {
              key = "<A-j>";
              action = ":bp<CR>";
            }
            {
              key = "<leader>bn";
              action = ":enew<CR>";
              options = {
                desc = "New buffer";
              };
            }
            {
              key = "<leader>bv";
              action = ":vnew<CR>";
              options = {
                desc = "New vertical buffer";
              };
            }
            {
              key = "<leader>bh";
              action = ":new<CR>";
              options = {
                desc = "New horizontal buffer";
              };
            }
            {
              key = "<leader>bd";
              action = ":bd<CR>";
              options = {
                desc = "Close buffer";
              };
            }
            {
              key = "<A-h>";
              action = ":tabprevious<CR>";
            }
            {
              key = "<A-l>";
              action = ":tabnext<CR>";
            }
            {
              key = "<leader>bt";
              action = ":tabnew<CR>";
              options = {
                desc = "New tab";
              };
            }
            {
              key = "<leader>bc";
              action = ":tabclose<CR>";
              options = {
                desc = "Close tab";
              };
            }
          ];
          copilot = [
            {
              key = "<leader>tc";
              action = ":CopilotChatToggle<CR>";
              options = {
                desc = "[T]oggle Copilot [C]hat";
              };
            }
            {
              key = "<leader>tp";
              action.__raw = builtins.readFile ./lua/copilot/toggle.lua;
              options = {
                desc = "[T]oggle Co[p]ilot";
              };
            }
          ];
          diagnostic = [
            {
              key = "<leader>q";
              action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
              options = {
                desc = "Open diagnostic [Q]uickfix list";
              };
            }
            {
              key = "<leader>e";
              action = "<cmd>lua vim.diagnostic.open_float()<CR>";
              options = {
                desc = "Show diagnostic [E]rror messages";
              };
            }
          ];
          window = [
            {
              key = "<C-h>";
              action = "<C-w><C-h>";
              options = {
                desc = "Move focus to the left window";
              };
            }
            {
              key = "<C-l>";
              action = "<C-w><C-l>";
              options = {
                desc = "Move focus to the right window";
              };
            }
            {
              key = "<C-j>";
              action = "<C-w><C-j>";
              options = {
                desc = "Move focus to the lower window";
              };
            }
            {
              key = "<C-k>";
              action = "<C-w><C-k>";
              options = {
                desc = "Move focus to the upper window";
              };
            }
          ];
          gitsigns = [
            {
              key = "<leader>hr";
              action = ":Gitsigns reset_hunk<CR>";
              options = {
                desc = "Reset hunk";
              };
            }
            {
              key = "<leader>hs";
              action = ":Gitsigns preview_hunk<CR>";
              options = {
                desc = "Show hunk";
              };
            }
            {
              key = "<leader>tb";
              action = ":Gitsigns toggle_current_line_blame<CR>";
              options = {
                desc = "Toggle blame";
              };
            }
            {
              key = "<leader>hb";
              action = ":Gitsigns blame_line<CR>";
              options = {
                desc = "Blame line";
              };
            }
            {
              key = "]h";
              action = ":Gitsigns next_hunk<CR>";
              options = {
                desc = "Jump to next git [h]unk";
              };
            }
            {
              key = "[h";
              action = ":Gitsigns prev_hunk<CR>";
              options = {
                desc = "Jump to previous git [h]hunk";
              };
            }
          ];
          telescope = [
            {
              key = "<leader>/";
              action = {
                __raw = ''
                  function()
                    require('telescope.builtin').current_buffer_fuzzy_find(
                      require('telescope.themes').get_dropdown {
                        winblend = 10, previewer = false,
                      }
                    );
                  end
                '';
              };
              options = {
                desc = "[/] Search in current buffer";
              };
            }
            {
              key = "<leader>s/";
              action = {
                __raw = ''
                  function()
                    require('telescope.builtin').live_grep {
                      grep_open_files = true,
                      prompt_title = 'Search in open files',
                    }
                  end
                '';
              };
              options = {
                desc = "[S]earch [/] in Open Files";
              };
            }
          ];
        }
        [
          builtins.attrValues
          builtins.concatLists
          (map (entry: entry // {mode = "n";}))
        ];
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
      _terminal =
        lib.mapAttrsToList
        (key: action: {
          mode = "t";
          inherit action key;
        })
        {
          # resize with arrows
          "<C-Down>" = "<cmd>resize -2<CR>";
          "<C-Up>" = "<cmd>resize +2<CR>";
          "<C-Right>" = "<cmd>vertical resize +2<CR>";
          "<C-Left>" = "<cmd>vertical resize -2<CR>";
        };
      terminal = [
        {
          mode = "t";
          key = "<Esc><Esc>";
          action = "<C-\\><C-n>";
          options = {
            desc = "Exit terminal mode";
          };
        }
      ];
    in
      config.lib.nixvim.keymaps.mkKeymaps
      {options.silent = true;}
      (_normal ++ normal ++ insert ++ visual ++ _terminal ++ terminal);

    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback = {
          __raw = "function() vim.highlight.on_yank() end";
        };
        event = "TextYankPost";
      }
    ];

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
          formatting = {fields = ["kind" "abbr" "menu"];};

          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<ESC>" = ''
              function ()
                cmp.mapping.close()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
              end
            '';
            "<C-j>" = "cmp.mapping.scroll_docs(4)";
            "<C-k>" = "cmp.mapping.scroll_docs(-4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          };

          sources = [
            {name = "nvim_lsp";}
            {name = "nvim_lua";}
            {name = "path";}
            {name = "luasnip";}
            {
              name = "buffer";
              keyword_length = 5;
              max_item_count = 10;
            }
          ];

          experimental = {
            native_menu = false;
            ghost_text = true;
          };
        };
      };

      comment = {
        enable = true;

        settings = {
          opleader.line = "<leader>k";
          toggler.line = "<leader>k";
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
          lspBuf = {
            "<C-q>" = "hover";
            "<leader>rn" = {
              action = "rename";
              desc = "[R]e[n]ame";
            };
            "gD" = {
              action = "declaration";
              desc = "[G]o to [D]eclaration";
            };
            # "<C-p>" = "signature_help";
          };

          extra = [
            {
              key = "gd";
              action = {
                __raw = "require('telescope.builtin').lsp_definitions";
              };
              options = {
                desc = "[G]o to [D]efinition";
              };
            }
            {
              key = "gr";
              action = {
                __raw = "require('telescope.builtin').lsp_references";
              };
              options = {
                desc = "[G]oto [R]eferences";
              };
            }
            {
              key = "gI";
              action = {
                __raw = "require('telescope.builtin').lsp_implementations";
              };
              options = {
                desc = "[G]o to [I]mplementation";
              };
            }
            {
              key = "<leader>D";
              action = {
                __raw = "require('telescope.builtin').lsp_type_definitions";
              };
              options = {
                desc = "Type [D]efinition";
              };
            }
            {
              key = "<leader>ds";
              action = {
                __raw = "require('telescope.builtin').lsp_document_symbols";
              };
              options = {
                desc = "[D]ocument [S]ymbol";
              };
            }
            {
              key = "<leader>ws";
              action = {
                __raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
              };
              options = {
                desc = "[W]orkspace [S]ymbol";
              };
            }
            {
              key = "<leader>ca";
              action = {
                __raw = "vim.lsp.buf.code_action";
              };
              mode = ["n" "x"];
              options = {
                desc = "[C]ode [A]ction";
              };
            }
          ];
        };

        onAttach = builtins.readFile ./lua/lsp/onAttach.lua;
      };

      lspkind = {
        enable = true;
        cmp = {
          enable = true;
          menu = {
            buffer = "[buf]";
            nvim_lsp = "[LSP]";
            path = "[path]";
            luasnip = "[snip]";
            nvim_lua = "[api]";
            gh_issues = "[issues]";
          };
        };
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
            alejandra.enable = true;
            stylua.enable = true;
            shfmt.enable = true;
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

      sleuth = {
        enable = true;
      };

      telescope = {
        enable = true;

        keymaps = {
          "<leader>sh" = {
            action = "help_tags";
            options = {
              desc = "[S]earch [H]elp";
            };
          };
          "<leader>sk" = {
            action = "keymaps";
            options = {
              desc = "[S]earch [K]eymaps";
            };
          };
          "<leader>sf" = {
            action = "find_files";
            options = {
              desc = "[S]earch [F]iles";
            };
          };
          "<leader>ss" = {
            action = "builtin";
            options = {
              desc = "[S]earch [S]elect Telescope";
            };
          };
          "<leader>sw" = {
            action = "grep_string";
            options = {
              desc = "[S]earch [W]ord";
            };
          };
          "<leader>sg" = {
            action = "live_grep";
            options = {
              desc = "[S]earch by [G]rep";
            };
          };
          "<leader>sd" = {
            action = "diagnotics";
            options = {
              desc = "[S]earch [D]iagnostics";
            };
          };
          "<leader>sr" = {
            action = "resume";
            options = {
              desc = "[S]earch [R]esume";
            };
          };
          "<leader>so" = {
            action = "oldfiles";
            options = {
              desc = "[S]earch [O]ld (Recent) files";
            };
          };
          "<leader><leader>" = {
            action = "buffers";
            options = {
              desc = "[ ] Find existing buffers";
            };
          };

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
          open_mapping = "[[<C-/>]]";
        };
      };

      treesitter = {
        enable = true;
        nixvimInjections = true;
        folding = true;
        settings = {
          auto_install = true;
          highlight = {
            enable = true;
          };
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-w>";
              node_incremental = "<C-w>";
              # scopeIncremental = "grc";
              node_decremental = "<C-S-w>";
            };
          };
          indent.enable = true;
        };
      };

      web-devicons = {
        enable = true;
      };

      which-key = {
        enable = true;
        settings = {
          icons = {
            keys = {
              Up = "<Up> ";
              Down = "<Down> ";
              Left = "<Left> ";
              Right = "<Right> ";
              C = "<C-…> ";
              M = "<M-…> ";
              D = "<D-…> ";
              S = "<S-…> ";
              CR = "<CR> ";
              Esc = "<Esc> ";
              ScrollWheelDown = "<ScrollWheelDown> ";
              ScrollWheelUp = "<ScrollWheelUp> ";
              NL = "<NL> ";
              BS = "<BS> ";
              Space = "<Space> ";
              Tab = "<Tab> ";
              F1 = "<F1>";
              F2 = "<F2>";
              F3 = "<F3>";
              F4 = "<F4>";
              F5 = "<F5>";
              F6 = "<F6>";
              F7 = "<F7>";
              F8 = "<F8>";
              F9 = "<F9>";
              F10 = "<F10>";
              F11 = "<F11>";
              F12 = "<F12>";
            };
          };

          spec = [
            {
              __unkeyed = "<leader>b";
              group = "[B]uffer";
            }
            {
              __unkeyed = "<leader>c";
              group = "[C]ode";
              mode = ["n" "x"];
            }
            {
              __unkeyed = "<leader>d";
              group = "[D]ocument";
            }
            {
              __unkeyed = "<leader>r";
              group = "[R]ename";
            }
            {
              __unkeyed = "<leader>s";
              group = "[S]earch";
            }
            {
              __unkeyed = "<leader>w";
              group = "[W]orkspace";
            }
            {
              __unkeyed = "<leader>t";
              group = "[T]oggle";
            }
            {
              __unkeyed = "<leader>h";
              group = "Git [H]unk";
              mode = ["n" "v"];
            }
          ];
        };
      };
    };
  };
}
