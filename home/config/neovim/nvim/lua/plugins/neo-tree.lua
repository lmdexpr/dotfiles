return {
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
}
