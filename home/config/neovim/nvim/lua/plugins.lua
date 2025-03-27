return {
  {
    'lewis6991/impatient.nvim',
    config = function ()
      require('impatient')
    end
  },

  {
    'neanias/everforest-nvim',
    lazy = false,
    priority = 1000,
    config = function ()
      require("everforest").setup({
        background = "hard",
      })

      require("everforest").load()
    end
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function ()
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
      ts.load_extension('file_browser')
      vim.keymap.set('n', '<leader>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', {})
    end
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-telescope/telescope.nvim' ,'nvim-lua/plenary.nvim' },
  },
  {
    'lambdalisue/fern.vim',
    dependencies = {
      'lambdalisue/fern-git-status.vim',
      'lambdalisue/nerdfont.vim',
      'lambdalisue/fern-renderer-nerdfont.vim',
      'lambdalisue/glyph-palette.vim'
    },
    config = function ()
      vim.g["fern#renderer"] = 'nerdfont'
      vim.keymap.set('n', '<C-e>', ':<C-u>Fern . -reveal=% -drawer -toggle<CR>', { noremap = true, silent = true })
    end
  },
  {
    'dinhhuy258/git.nvim',
    event = 'InsertEnter',
    config = function ()
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
    config = function () 
      require("nvim-treesitter.configs").setup {
        auto_install = true,
        highlight = { enable = true },
        indent    = { enable = true }
      }
    end
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
  },
  {
    "uga-rosa/ccc.nvim",
    config = function ()
      require("ccc").setup({
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
      })
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
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      provider = "copilot", -- copilotを使用
      -- auto_suggestions_provider = "copilot",
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
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
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function ()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      cmp.setup(require('plugins.cmp').config(cmp, lspkind))

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

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.cmd('let g:vsnip_filetypes = {}')
    end
  },
  {'hrsh7th/cmp-nvim-lsp',                 event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-nvim-lsp-signature-help',  event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp', 'hrsh7th/cmp-nvim-lsp' }},
  {'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp', 'hrsh7th/cmp-nvim-lsp' }},
  {'onsails/lspkind.nvim',                 event = 'LspAttach',   dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-buffer',                   event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-path',                     event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-vsnip',                    event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-cmdline',                  event = 'ModeChanged', dependencies = { 'hrsh7th/nvim-cmp' }}, 
  {'hrsh7th/cmp-calc',                     event = 'InsertEnter', dependencies = { 'hrsh7th/nvim-cmp' }}, 

  {
    'hrsh7th/vim-vsnip',
    event = 'InsertEnter',
    config = function ()
      vim.api.nvim_set_keymap('i', '<C-l>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-l>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('i', '<C-h>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-h>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
      vim.g.vsnip_snippet_dir = '~/.config/nvim/snippet'
    end
  },
  {'hrsh7th/vim-vsnip-integ', event = 'InsertEnter'},
  {'rafamadriz/friendly-snippets', event = 'InsertEnter'},

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          section_separators = { left = '', right = ''},
          component_separators = { left = '|', right = '|' },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {'filename'},
          lualine_b = {'branch'},
          lualine_c = {
            "'%='",
            {
              'diff',
              symbols = {added = ' ', modified = ' ', removed = ' '},
              separator = "  |  ",
            },
            {
              'diagnostics',
              symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
            },
          },
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {}, lualine_b = {}, lualine_c = {},
          lualine_x = {}, lualine_y = {}, lualine_z = {},
        },
        extension = {'lazy', 'fern'},
      }
    end
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function ()
      vim.o.termguicolors = true
      require("bufferline").setup{
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
          truncate_names = true, -- whether or not tab names should be truncated
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          always_show_bufferline = false,
          hover = { enabled = true, delay = 200, reveal = {'close'} },
        }
      }
      vim.keymap.set('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
      vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', {})
      vim.keymap.set('n', '@', '<Cmd>BufferLineCloseRight<CR>', {})
      vim.keymap.set('n', '!', '<Cmd>BufferLineCloseLeft<CR>', {})
    end
  },

  {
    'neovim/nvim-lspconfig',
    config = function ()
      local opts = { noremap=true, silent=true }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
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
        'ocamllsp', 
        'intelephense', 
        'rust_analyzer', 
        'gopls', 
        'csharp_ls', 
        'ts_ls', 
        'ruby_lsp', 
        'metals',
        'elmls',
        'pylsp',
        'jdtls',
      }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup{
          on_attach = on_attach,
          autostart = true,
        }
      end
    end
  },

  {
    'ToruNiina/satysfi.vim',
    ft = 'satysfi',
  }
}
