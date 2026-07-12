---@type vim.lsp.Config
return {
  cmd = { 'flix', 'lsp' },
  filetypes = { 'flix' },
  root_markers = { 'flix.toml', '.git' },
}
