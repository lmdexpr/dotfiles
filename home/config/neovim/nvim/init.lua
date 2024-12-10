-----------
-- color --
-----------
if vim.fn.exists('+termguicolors') == 1 then
  vim.o.termguicolors = true
end

-------------
-- augroup --
-------------
local function on_ft(ft, cb)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = ft,
    callback = cb,
  })
end

on_ft('php', function()
  vim.bo.tabstop     = 4
  vim.bo.softtabstop = 4
  vim.bo.shiftwidth  = 4
  vim.bo.autoindent  = true
end)

vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = '*.saty',
  callback = function ()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "satysfi")
  end
})

-------------
-- options --
-------------
local options = {
  encoding     = "utf-8",
  fileencoding = "utf-8",
  mouse        = "a",
  expandtab    = true,
  shiftwidth   = 2,
  tabstop      = 2,
  autoindent   = true,
  autoread     = true,
  number       = true,
  background   = "dark",
  showmatch    = true,
  wildmenu     = true,
  wrapscan     = true,
  clipboard    = "unnamedplus",
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

------------
-- keymap --
------------
local keymap_options = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = 

--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", keymap_options)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- no highlight
vim.api.nvim_set_keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", keymap_options)

---------------
-- lazy.nvim --
---------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = require('plugins')
require('lazy').setup(plugins, {
  lockfile = "~/.lazy.lock",
  reset_packpath = false,
})
