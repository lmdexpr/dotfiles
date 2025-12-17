local function set_4tab(ft)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = ft,
    callback = function()
      vim.bo.tabstop     = 4
      vim.bo.softtabstop = 4
      vim.bo.shiftwidth  = 4
      vim.bo.autoindent  = true
    end,
  })
end

for _, ft in pairs({ 'php', 'java' }) do
  set_4tab(ft)
end

local function set_pattern_filetype(pattern, filetype)
  vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = pattern,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
    end
  })
end

for pt, ft in pairs({
  ['*.saty'] = 'satysfi',
}) do
  set_pattern_filetype(pt, ft)
end
