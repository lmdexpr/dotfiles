local function on_ft(ft, cb)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = ft,
    callback = cb,
  })
end

for _,ft in pairs({'php', 'java'}) do
  on_ft(ft, function()
    vim.bo.tabstop     = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth  = 4
    vim.bo.autoindent  = true
  end)
end

vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = '*.saty',
  callback = function ()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "satysfi")
  end
})
