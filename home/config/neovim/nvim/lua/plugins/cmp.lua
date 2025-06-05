return {
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
}
