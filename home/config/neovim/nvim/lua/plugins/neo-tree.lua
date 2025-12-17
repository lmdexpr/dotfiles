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
    opts = {
      close_if_last_window = true,
    },
    config = function(_)
      vim.keymap.set('n', '<C-e>', ':<C-u>Neotree<CR>', { noremap = true, silent = true })
    end
  },
}
