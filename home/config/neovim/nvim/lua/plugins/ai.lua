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

  {
    "greggh/claude-code.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup({
        -- Terminal window settings
        window = {
          split_ratio = 0.3,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
          position = "rightbelow vsplit",  -- Position of the window: "botright", "topleft", "vertical", "rightbelow vsplit", etc.
          enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
          hide_numbers = true,    -- Hide line numbers in the terminal window
          hide_signcolumn = true, -- Hide the sign column in the terminal window
        },
        -- File refresh settings
        refresh = {
          enable = true,           -- Enable file change detection
          updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
          timer_interval = 1000,   -- How often to check for file changes (milliseconds)
          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true,     -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Command settings
        command = "claude --mcp-config=$XDG_CONFIG_HOME/claude/servers.json",        -- Command used to launch Claude Code
        -- Command variants
        command_variants = {
          -- Conversation management
          continue = "--continue", -- Resume the most recent conversation
          resume = "--resume",     -- Display an interactive conversation picker

          -- Output options
          verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = "<C-,>",       -- Normal mode keymap for toggling Claude Code, false to disable
            terminal = "<C-,>",     -- Terminal mode keymap for toggling Claude Code, false to disable
            variants = {
              continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
              verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
        }
      })

      vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
    end
  },

  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",
  --   -- lazy = false,
  --   version = false,
  --   opts = {
  --     provider = vim.env.AVANTE_PROVIDER or "copilot", -- :Copilot auth
  --     -- provider = "vertex",
  --     -- provider = "vertex_claude",
  --     -- provider = "gemini",
  --     -- auto_suggestions_provider = "copilot",
  --     behaviour = {
  --       enable_cursor_planning_mode = true,
  --     },
  --     hints = { enabled = false },
  --     providers = {
  --       copilot = {
  --         model = "claude-sonnet-4",
  --       },
  --       vertex = {
  --         -- require
  --         -- export LOCATION=<location>
  --         -- export PROJECT_ID=<projcet id>
  --         endpoint =
  --         "https://LOCATION-aiplatform.googleapis.com/v1/projects/PROJECT_ID/locations/LOCATION/publishers/google/models",
  --         model = "gemini-2.5-pro-preview-05-06",
  --         timeout = 60000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0,
  --           max_tokens = 65534,
  --         },
  --       },
  --       vertex_claude = {
  --         -- require
  --         -- export LOCATION=<location>
  --         -- export PROJECT_ID=<projcet id>
  --         endpoint =
  --         "https://LOCATION-aiplatform.googleapis.com/v1/projects/PROJECT_ID/locations/LOCATION/publishers/antrhopic/models",
  --         model = "claude-sonnet-4@20250514",
  --         timeout = 60000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0,
  --           max_tokens = 32768,
  --         },
  --       },
  --       gemini = {
  --         -- require export GEMINI_API_KEY=<api key>
  --         model = "gemini-2.5-pro-preview-05-06",
  --         timeout = 60000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0,
  --           max_tokens = 65534,
  --         },
  --       },
  --     },
  --     window = {
  --       ask = {
  --         -- floating = true,
  --       }
  --     },
  --     system_prompt = function()
  --       local hub = require("mcphub").get_hub_instance()
  --       return hub:get_active_servers_prompt()
  --     end,
  --     -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
  --     custom_tools = function()
  --       return {
  --         require("mcphub.extensions.avante").mcp_tool(),
  --       }
  --     end,
  --     disabled_tools = {
  --       "list_files", -- Built-in file operations
  --       "search_files",
  --       "read_file",
  --       "create_file",
  --       "rename_file",
  --       "delete_file",
  --       "create_dir",
  --       "rename_dir",
  --       "delete_dir",
  --       "bash", -- Built-in terminal access
  --     },
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = "make",
  --   dependencies = {
  --     'nvim-treesitter/nvim-treesitter',
  --     "stevearc/dressing.nvim",
  --     "hrsh7th/nvim-cmp",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --     "zbirenbaum/copilot.lua",
  --     {
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --     {
  --       "ravitemer/mcphub.nvim",
  --       dependencies = {
  --         "nvim-lua/plenary.nvim",
  --       },
  --       cmd = "MCPHub",
  --       -- build = "npm install -g mcp-hub@latest",
  --       build = "bundled_build.lua",
  --       config = function()
  --         require("mcphub").setup({
  --           auto_approve = false,
  --           use_bundled_binary = true,
  --         })
  --       end,
  --     },
  --   },
  -- },
}
