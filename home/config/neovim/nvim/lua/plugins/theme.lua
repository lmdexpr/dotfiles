return {
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
}
