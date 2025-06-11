return {
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
          },
        },
        sections = {
          lualine_a = { 'filetype' }, lualine_b = { 'fileformat', 'encoding' },
          lualine_c = {
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
          lualine_a = { 'filename' },
          lualine_b = {}, lualine_c = {},
          lualine_x = {}, lualine_y = {}, lualine_z = {},
        },
        extension = {},
      }
    end
  },
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
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
}
