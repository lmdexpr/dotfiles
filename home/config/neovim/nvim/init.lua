vim.loader.enable()

require('config.color')
require('config.augroup')
require('config.options')
require('config.keymap')
require('config.lazy')
require('config.lsp')

require('vim._core.ui2').enable({})
