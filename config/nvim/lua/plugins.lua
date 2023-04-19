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
      vim.keymap.set('n', '<leader>fb', ':Telescope file_browser<CR>', {})
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
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    config = function ()
      require('nvim-treesitter').setup({})
      vim.cmd(':TSEnable highlight')
    end
  },
  {
    'github/copilot.vim',
    config = function ()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
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
      require('lualine').setup({
        theme = 'auto',
      })
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

  {
    'wakatime/vim-wakatime',
  },

  {
    'neovim/nvim-lspconfig',
    event = 'LspAttach',
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
      vim.opt_global.completeopt = { "menu", "noinsert", "noselect" }
      vim.opt_global.shortmess:remove("F"):append("c")

      local function nmap(key, map)
        local options = { noremap = true }
        vim.api.nvim_set_keymap('n', key, map, options)
      end
      nmap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
      nmap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
      nmap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
      nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
      nmap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
      nmap("<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
      nmap("<space>f", "<cmd>lua vim.lsp.buf.format { async = true } <CR>")
      nmap("<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>")

      vim.api.nvim_create_augroup('lsp', {})
      vim.api.nvim_create_autocmd('FileType', {
        group = 'lsp',
        pattern = 'scala',
        callback = function ()
          vim.opt_local.omnifunc = vim.lsp.omnifunc
        end
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'lsp',
        pattern = {'java', 'scala', 'sbt'},
        callback = function ()
          require('metals').initialize_or_attach(metals_config)
        end
      })

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
