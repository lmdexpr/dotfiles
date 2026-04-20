return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    event = "VeryLazy",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          use_libuv_file_watcher = true,
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.cmd("checktime")
            end,
          },
        },
      })

      vim.keymap.set('n', '<C-e>', ':<C-u>Neotree<CR>', { noremap = true, silent = true })

      -- Refresh neo-tree on focus gain (for external git operations)
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          if package.loaded["neo-tree.sources.manager"] then
            require("neo-tree.command").execute({ action = "show", source = "filesystem" })
          end
        end,
      })

      -- Ensure nvim quits when neo-tree is the last window
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local tree_wins = {}
          local floating_wins = {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match("neo%-tree filesystem") ~= nil then
              table.insert(tree_wins, w)
            end
            if vim.api.nvim_win_get_config(w).relative ~= '' then
              table.insert(floating_wins, w)
            end
          end
          if 1 == #wins - #floating_wins - #tree_wins then
            -- Close all neo-tree windows when neo-tree is the last window
            for _, w in ipairs(tree_wins) do
              vim.api.nvim_win_close(w, true)
            end
          end
        end
      })
    end
  },
}
