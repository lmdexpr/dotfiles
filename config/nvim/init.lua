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
end)

vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = '*.saty',
  command = 'set filetype = satysfi',
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
  number       = true,
  background   = "dark",
  showmatch    = true,
  wildmenu     = true,
  wrapscan     = true,
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
require('lazy').setup(plugins)

-------------
-- plugins --
-------------
vim.keymap.set('n', '<C-e>', ':<C-u>Fern . -reveal=% -drawer -toggle<CR>', { noremap = true, silent = true })

-----------
-- OCaml --
-----------
vim.api.nvim_exec(
[[
let s:opam_share_dir = system("opam var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"

let s:opam_bin_dir = system("opam var bin")
let s:opam_bin_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp+=" . s:opam_bin_dir . "/ocamlformat"
]],
false)
