return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>b', builtin.buffers, {})
      vim.keymap.set('n', '<leader>r', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>g', builtin.git_status, {})

      local ts = require('telescope')
      local ts_actions = require("telescope.actions")

      ts.setup {
        defaults = {
          mappings = {
            i = {
              ["<C-q>"] = ts_actions.close
            }
          }
        },
        extensions = {
          file_browser = {
            dir_icon = "",
            dir_icon_hl = "Default",
            git_status = true,
          },
        }
      }
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      close_if_last_window = true,
      filesystem = {
        commands = {
          avante_add_files = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative_path = require('avante.utils').relative_path(filepath)

            local sidebar = require('avante').get()

            local open = sidebar:is_open()
            -- ensure avante sidebar is open
            if not open then
              require('avante.api').ask()
              sidebar = require('avante').get()
            end

            sidebar.file_selector:add_selected_file(relative_path)

            -- remove neo tree buffer
            if not open then
              sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
            end
          end,
        },
      },
    },
    config = function(_, opts)
      vim.keymap.set('n', '<C-e>', ':<C-u>Neotree<CR>', { noremap = true, silent = true })

      -- Setup neo-tree with merged options and mappings
      require('neo-tree').setup(vim.tbl_deep_extend('force', opts, {
        filesystem = {
          window = {
            mappings = {
              ['oa'] = 'avante_add_files',
            },
          },
        },
      }))
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    event = 'VeryLazy',
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
          always_divide_middle = true,
          disabled_filetypes = {
            'neo-tree',
            'Avante', 'AvanteSelectedFiles', 'AvanteInput',
          },
        },
        sections = {
          lualine_a = { 'filename' }, lualine_b = { 'filetype' },
          lualine_c = {
            'fileformat',
            'encoding',
            {
              'diagnostics',
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            },
          },
          lualine_x = {
            {
              'diff',
              symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
            'branch',
          },
          lualine_y = { 'progress' }, lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = { 'filename' }, lualine_b = { 'filetype' },
          lualine_c = {},
          lualine_x = {}, lualine_y = {}, lualine_z = {},
        },
        extension = {},
      }
    end
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      vim.o.termguicolors = true
      require("bufferline").setup {
        options = {
          mode = "buffers",
          numbers = function(opts) return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal)) end,
          buffer_close_icon = 'x',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          max_name_length = 18,
          max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
          truncate_names = true,  -- whether or not tab names should be truncated
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          always_show_bufferline = false,
          hover = { enabled = true, delay = 200, reveal = { 'close' } },
        }
      }
      vim.keymap.set('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
      vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', {})
      vim.keymap.set('n', '@', '<Cmd>BufferLineCloseRight<CR>', {})
      vim.keymap.set('n', '!', '<Cmd>BufferLineCloseLeft<CR>', {})
    end
  },

  {
    'dinhhuy258/git.nvim',
    event = 'InsertEnter',
    config = function()
      require('git').setup({
        default_mappings = false,
        keymaps = {
          blame = "<Leader>gb",
          quit_blame = "q",
          blame_commit = "<CR>",

          browse = "<Leader>go",

          open_pull_request = "<Leader>gp",
          create_pull_request = "<Leader>gn",

          diff = "<Leader>gd",
          diff_close = "<Leader>gD",

          revert = "<Leader>gr",
          revert_file = "<Leader>gR",
        },
        target_branch = "master",
      })
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true }
      }
    end
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = "<C-j>",
            accept_word = false,
            accept_line = false,
            next = "<C-l>",
            prev = "<C-h>",
            dismiss = "<C-]>",
          },
        },
        lsp_binary = "$XDG_CONFIG_HOME/nvim/copilot/bin/copilot-language-server",
        -- $ export XDG_CONFIG_HOME=$HOME/.config
        -- $ npm install @github/copilot-language-server -g --prefix ~/.config/nvim/copilot/
        -- $ chmod +x ~/.config/nvim/copilot/bin/copilot-language-server
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    -- lazy = false,
    version = false,
    opts = {
      provider = vim.env.AVANTE_PROVIDER or "copilot", -- :Copilot auth
      -- provider = "vertex",
      -- provider = "vertex_claude",
      -- provider = "bedrock",
      -- provider = "gemini",
      -- auto_suggestions_provider = "copilot",
      behaviour = {
        enable_cursor_planning_mode = true,
      },
      hints = { enabled = false },
      copilot = {
        model = "claude-3.7-sonnet",
      },
      vertex = {
        -- require
        -- export LOCATION=<location>
        -- export PROJECT_ID=<projcet id>
        endpoint =
        "https://LOCATION-aiplatform.googleapis.com/v1/projects/PROJECT_ID/locations/LOCATION/publishers/google/models",
        model = "gemini-2.5-pro-preview-05-06",
        timeout = 60000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 65534,
      },
      vertex_claude = {
        -- require
        -- export LOCATION=<location>
        -- export PROJECT_ID=<projcet id>
        endpoint =
        "https://LOCATION-aiplatform.googleapis.com/v1/projects/PROJECT_ID/locations/LOCATION/publishers/antrhopic/models",
        model = "claude-sonnet-4@20250514",
        timeout = 60000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 32768,
      },
      bedrock = {
        -- require export BEDROCK_KEYS=$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_REGION,$AWS_SESSION_TOKEN
        model = "anthropic.claude-3-5-sonnet-20241022-v2:0",
        timeout = 60000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 32768,
      },
      gemini = {
        -- require export GEMINI_API_KEY=<api key>
        model = "gemini-2.5-pro-preview-05-06",
        timeout = 60000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 65534,
      },
      window = {
        ask = {
          floating = true,
        }
      },
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
      disabled_tools = {
        "list_files", -- Built-in file operations
        "search_files",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash", -- Built-in terminal access
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      "stevearc/dressing.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
      {
        "ravitemer/mcphub.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
        cmd = "MCPHub",
        -- build = "npm install -g mcp-hub@latest",
        build = "bundled_build.lua",
        config = function()
          require("mcphub").setup({
            auto_approve = false,
            use_bundled_binary = true,
          })
        end,
      },
    },
  },


  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end
        },

        window = {
          completion = cmp.config.window.bordered({
            border = 'single'
          }),
          documentation = cmp.config.window.bordered({
            border = 'single'
          }),
        },

        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),

        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            ellipsis_char = '...',
          })
        },

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'calc' },
        }, {
          { name = 'buffer', keyword_length = 2 },
        })
      }

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = 'nvim_lsp_document_symbol' } },
          { { name = 'buffer' } }
        )
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = 'path' } },
          { { name = 'cmdline', keyword_length = 2 } }
        )
      })

      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.cmd('let g:vsnip_filetypes = {}')
    end
  },
  { 'hrsh7th/cmp-nvim-lsp',                 event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-nvim-lsp-signature-help',  event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp', 'hrsh7th/cmp-nvim-lsp' } },
  { 'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp', 'hrsh7th/cmp-nvim-lsp' } },
  { 'onsails/lspkind.nvim',                 event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-buffer',                   event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-path',                     event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-vsnip',                    event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-cmdline',                  event = 'ModeChanged', dependencies = { 'hrsh7th/nvim-cmp' } },
  { 'hrsh7th/cmp-calc',                     event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' } },

  {
    'hrsh7th/vim-vsnip',
    event = 'InsertEnter',
    config = function()
      vim.api.nvim_set_keymap('i', '<C-l>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-l>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('i', '<C-h>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-h>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
      vim.g.vsnip_snippet_dir = '~/.config/nvim/snippet'
    end
  },
  { 'hrsh7th/vim-vsnip-integ',      event = 'InsertEnter' },
  { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },

  {
    'neovim/nvim-lspconfig',
    config = function()
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
      end
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local servers = {
        'nil_ls',
        'ocamllsp', 'rescriptls', -- 'reason_ls',
        'rust_analyzer',
        'gopls',
        'metals', 'jdtls',
        'csharp_ls',
        'ts_ls', 'elmls',
        'ruby_lsp',
        'pylsp',
        'intelephense',
        'lua_ls',
      }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
          autostart = true,
          capabilities = capabilities,
        }
      end
    end
  },
  { 'ToruNiina/satysfi.vim',           ft = 'satysfi', },
  { 'rescript-lang/vim-rescript',      ft = 'rescript' },
  { 'reasonml-editor/vim-reason-plus', ft = 'reason' },
  {
    'ocaml-mlx/ocaml_mlx.nvim',
    ft = 'ocaml',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require 'ocaml_mlx'
    end
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>ft",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        -- lua = { "stylua" },
      },
      -- Set default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500 },
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  -- {
  --   'neanias/everforest-nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function ()
  --     require("everforest").setup({
  --       background = "hard",
  --     })

  --     require("everforest").load()
  --   end
  -- }

  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {
  --     flavour = "frappe", -- latte, frappe, macchiato, mocha
  --     transparent_background = false,
  --     integrations = {
  --       cmp = true,
  --       render_markdown = true,
  --       nvimtree = true,
  --       treesitter = true,
  --       native_lsp = {
  --         enabled = true,
  --         virtual_text = {
  --           errors = { "italic" },
  --           hints = { "italic" },
  --           warnings = { "italic" },
  --           information = { "italic" },
  --           ok = { "italic" },
  --         },
  --         underlines = {
  --           errors = { "underline" },
  --           hints = { "underline" },
  --           warnings = { "underline" },
  --           information = { "underline" },
  --           ok = { "underline" },
  --         },
  --         inlay_hints = {
  --           background = true,
  --         },
  --       },
  --       telescope = {
  --         enabled = true,
  --       }
  --     }
  --   },
  --   config = function(_, opts)
  --     require("catppuccin").setup(opts)
  --     vim.cmd.colorscheme "catppuccin"
  --   end
  -- }

  {
    'shaunsingh/nord.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd [[colorscheme nord]]

      -- Example config in lua
      vim.g.nord_contrast = true
      vim.g.nord_borders = false
      vim.g.nord_disable_background = false
      vim.g.nord_italic = false
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = false

      -- Load the colorscheme
      require('nord').set()
    end,
  }
}
