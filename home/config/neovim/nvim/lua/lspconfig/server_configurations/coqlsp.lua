local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = {'coq-lsp', '--std'},
    filetypes = {'coq'},
    root_dir =
      function(name)
        return util.find_git_ancestor(name) or vim.loop.os_homedir()
      end,
    settings = {},
  }
}
