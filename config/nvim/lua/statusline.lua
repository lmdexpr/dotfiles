-- ref. https://ryota2357.com/blog/2023/nvim-custom-statusline-tabline/
-- ref. https://nuxsh.is-a.dev/blog/custom-nvim-statusline.html

local M = {}
local fn = vim.fn
local highlight = require('util.highlight')
highlight.link { StatusLine = 'Normal' }
highlight.set {
  StatusLineNormal = { fg = '#4caf50', bg = 'NONE' },
  StatusLineInsert = { fg = '#03a9f4', bg = 'NONE' },
  StatusLineVisual = { fg = '#ff9800', bg = 'NONE' },
  StatusLineReplace = { fg = '#ff5722', bg = 'NONE' },
  StatusLineCommand = { fg = '#8eacbb', bg = 'NONE' },
  StatusLineInactive = { fg = '#607080', bg = 'NONE' },
}
---@return string
local function mode()
  local m = string.lower(vim.fn.mode())
  if m == 'n' then
    return 'normal'
  elseif m == 'i' then
    return 'insert'
  elseif m == 'c' then
    return 'command'
  elseif m == 'v' or m == '^V' or m == 's' then
    return 'visual'
  elseif m == 'r' then
    return 'replace'
  end
  return 'other'
end

---@return number
local function modified_bg_bufs_count()
  local cnt = 0
  for i = 1, fn.bufnr('$') do
    if fn.bufexists(i) == 1 and fn.buflisted(i) == 1 and fn.getbufvar(i, 'buftype') == '' and
      fn.filereadable(fn.expand('#' .. i .. ':p')) and i ~= fn.bufnr('%') and
      fn.getbufvar(i, '&modified') == 1 then
      cnt = cnt + 1
    end
  end
  return cnt
end

local component = {
  filePath = function()
    local path = fn.fnamemodify(fn.expand("%"), ":~:.")
    if path == '' then
      return '', 0
    end
    path = ' ' .. path .. ' '
    return '%#StatusLine#' .. path, fn.strdisplaywidth(path)
  end,
  modified = function()
    local mark = vim.o.modified and '' or ''
    local count = modified_bg_bufs_count()
    if count ~= 0 then
      mark = mark .. ' ( ' .. tostring(count) .. ')'
    end
    mark = ' ' .. mark .. ' '
    return '%#StatusLine#' .. mark, fn.strdisplaywidth(mark)
  end,
  position = function()
    local l = tostring(vim.fn.line('.'))
    local c = tostring(vim.fn.col('.'))
    local pos = ' ' .. l .. ':' .. c .. ' '
    return '%#StatusLine#' .. pos, fn.strdisplaywidth(pos)
  end
}

---@return string
function M.active()
  local hl = (function()
    local match = {
      normal = '%#StatusLineNormal#',
      visual = '%#StatusLineVisual#',
      insert = '%#StatusLineInsert#',
      replace = '%#StatusLineReplace#',
      command = '%#StatusLineCommand#'
    }
    return match[mode()] or '%#StatusLine#'
  end)()
  local bar = function(count)
    return hl .. string.rep('━', count)
  end
  local columnWidth = vim.o.columns
  local file, fileWidth = component.filePath()
  local modified, modifiedWidth = component.modified()
  local pos, posWidth = component.position()
  local width = columnWidth - modifiedWidth - fileWidth - posWidth - 2
  return bar(1)
  .. modified
  .. bar(math.floor(width / 2))
  .. file
  .. bar(math.ceil(width / 2))
  .. pos
  .. bar(1)
end

function M.inactive()
  return '%#StatusLineInactive#' .. string.rep('━', vim.o.columns)
end

return M
