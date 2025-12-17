local keymap_options = { noremap = true, silent = true }

--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", keymap_options)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- no highlight
vim.api.nvim_set_keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", keymap_options)
