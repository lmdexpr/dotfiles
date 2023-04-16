return {
  {
    'lewis6991/impatient.nvim',
    config = function ()
      require('impatient')
    end
  },

  {
    'catppuccin/nvim',
    dependencies = { 'telescope.nvim', 'nvim-treesitter' },
    config = function()
      local catppuccin_config = require('plugins.catppuccin').config()
      require("catppuccin").setup(catppuccin_config)
      vim.cmd.colorscheme "catppuccin"
    end
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function ()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Space>ff', builtin.find_files, {})
      vim.keymap.set('n', '<Space>b', builtin.buffers, {})
      vim.keymap.set('n', '<Space>r', builtin.live_grep, {})
      vim.keymap.set('n', '<Space>g', builtin.git_status, {})

      local ts = require('telescope')
      local ts_actions = require("telescope.actions")

      ts.setup {
        extensions = {
          file_browser = {
            dir_icon = "",
            dir_icon_hl = "Default",
            git_status = true,
          },
        }
      }
      ts.load_extension('file_browser')
      vim.keymap.set('n', '<Space>fb', ':Telescope file_browser<CR>', {})
    end
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' ,'nvim-lua/plenary.nvim' },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate"
  },
  {
    'github/copilot.vim',
    config = function ()
      vim.g.copilot_no_tab_map = true
    end
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter, CmdlineEnter',
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
  {'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter'}, 
  {'hrsh7th/cmp-buffer', event = 'InsertEnter'},
  {'hrsh7th/cmp-path', event = 'InsertEnter'},
  {'hrsh7th/cmp-vsnip', event = 'InsertEnter'},
  {'hrsh7th/cmp-cmdline', event = 'ModeChanged'},
  {'hrsh7th/cmp-nvim-lsp-signature-help', event = 'InsertEnter'},
  {'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'InsertEnter'},
  {'hrsh7th/cmp-calc', event = 'InsertEnter'},
  {'onsails/lspkind.nvim', event = 'InsertEnter'},

  {
    'hrsh7th/vim-vsnip',
    event = 'InsertEnter',
    config = function ()
      vim.api.nvim_set_keymap('i', '<C-j>', 'vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<C-j>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-j>', 'vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<C-j>"', { expr = true })
      vim.api.nvim_set_keymap('i', '<C-f>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-f>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-f>"', { expr = true })
      vim.api.nvim_set_keymap('i', '<C-b>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
      vim.api.nvim_set_keymap('s', '<C-b>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-b>"', { expr = true })
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
      require('lualine').setup()
    end
  },
  {
    'akinsho/bufferline.nvim',
    version = "v3.*",
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

  'wakatime/vim-wakatime',

  {
    'neovim/nvim-lspconfig',
    event = 'BufEnter',
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

      local servers = { 'ocamllsp', 'intelephense', 'rust_analyzer', 'gopls', 'csharp_ls' }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup{
          on_attach = on_attach
        }
      end

      local configs = require'lspconfig/configs'
      configs.coqlsp = {
        default_config = {
          cmd = {'coq-lsp', '--std'},
          filetypes = {'coq'},
          root_dir =
          function(name)
            return lspconfig.util.find_git_ancestor(name) or vim.loop.os_homedir()
          end,
          settings = {},
        };
      }
      configs.satysfilsp = {
        default_config = {
          cmd = {'satysfi-language-server'},
          filetypes = {'satysfi'},
          root_dir =
          function(name)
            return lspconfig.util.find_git_ancestor(name) or vim.loop.os_homedir()
          end,
          settings = {},
        };
      }
    end
  },
  {
    'scalameta/nvim-metals',
    ft = 'scala',
    config = function ()
      local cmd = vim.cmd
      local function map(mode, lhs, rhs, opts)
        local options = { noremap = true }
        if opts then
          options = vim.tbl_extend("force", options, opts)
        end
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
      end
      ------------------------------------------------
      -- global
      ------------------------------------------------
      vim.opt_global.completeopt = { "menu", "noinsert", "noselect" }
      vim.opt_global.shortmess:remove("F"):append("c")
      ------------------------------------------------
      -- LSP mapping
      ------------------------------------------------
      map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
      map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
      map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
      map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
      map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
      map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
      map("n", "<space>f", "<cmd>lua vim.lsp.buf.format { async = true } <CR>")
      map("n", "<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>")
      ------------------------------------------------
      -- command
      ------------------------------------------------
      cmd([[augroup lsp]])
      cmd([[autocmd!]])
      cmd([[autocmd FileType scala setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
      -- Java のLSPも利用する場合はここがコンフリクトする可能性がある
      cmd([[autocmd FileType java,scala,sbt lua require("metals").initialize_or_attach(metals_config)]])
      cmd([[augroup end]])
      ------------------------------------------------
      -- Metals Settings
      ------------------------------------------------
      metals_config = require("metals").bare_config()
      metals_config.settings = {
        excludedPackages = { "akka.actor.typed.javadsl" },
        showImplicitArguments = true,
        showInferredType = true,
      }
      cmd([[:command TVP  lua require("metals.tvp").toggle_tree_view()]])
      cmd([[:command TVPR lua require("metals.tvp").reveal_in_tree()]])
      cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
    end
  }
}
