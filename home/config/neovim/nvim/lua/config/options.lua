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
  foldexpr     = "v:lua.vim.treesitter.foldexpr()",
  foldlevel    = 99,
  foldmethod   = "expr",
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

local venv_python = vim.fn.expand("~/.local/share/nvim/venv/bin/python3")
if vim.uv.fs_stat(venv_python) then
  vim.g.python3_host_prog = venv_python
end

vim.diagnostic.config({ virtual_text = true })

vim.filetype.add({
  extension = {
    flix = "flix",
  },
})
