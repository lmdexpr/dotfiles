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

vim.diagnostic.config({ virtual_text = true })
