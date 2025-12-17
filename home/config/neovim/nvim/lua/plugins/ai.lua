return {
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
}
