local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local buf = args.buf

    -- See https://neovim.io/doc/user/lsp.html#lsp-defaults
    -- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
    -- "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
    -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
    -- "grr" is mapped in Normal mode to vim.lsp.buf.references()
    -- "grt" is mapped in Normal mode to vim.lsp.buf.type_definition()
    -- "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
    -- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()
    -- "an" and "in" are mapped in Visual mode to outer and inner incremental selections, respectively, using vim.lsp.buf.selection_range()

    if client:supports_method("textDocument/definition") then
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
    end

    if client:supports_method("textDocument/hover") then
      vim.keymap.set("n", "<leader>k",
        function() vim.lsp.buf.hover({ border = "single" }) end,
        { buffer = buf, desc = "Show hover documentation" })
    end
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.enable({
  'nil_ls',
  'ocamllsp', 'rescriptls', -- 'reason_ls',
  'rust_analyzer',
  'gopls',
  'metals', 'jdtls', 'kotlin_language_server',
  'csharp_ls',
  'ts_ls', 'elmls',
  'ruby_lsp',
  'pylsp',
  'intelephense',
  'lua_ls',
})
