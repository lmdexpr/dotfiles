local icons = require('sidetree.icons')

local M = {}

local state = {
  buf = nil,
  win = nil,
  root = nil,
  expanded = {},
  entries = {},
  git_status = {},
  untracked_dirs = {},
  ignored_cache = {},
  diag = {},
  show_hidden = false,
}

local ns = vim.api.nvim_create_namespace('sidetree')
local IGNORE = { ['.git'] = true }

-- forward declarations
local render

-- ===== Tree =====

local function list_dir(path)
  local entries = {}
  for name, ftype in vim.fs.dir(path) do
    if not IGNORE[name] then
      entries[#entries + 1] = {
        name = name,
        type = ftype,
        path = path .. '/' .. name,
      }
    end
  end
  table.sort(entries, function(a, b)
    if (a.type == 'directory') ~= (b.type == 'directory') then
      return a.type == 'directory'
    end
    return a.name < b.name
  end)
  return entries
end

local function build_entries()
  local result = {}
  local function walk(path, depth)
    for _, e in ipairs(list_dir(path)) do
      local hidden = e.name:sub(1, 1) == '.'
      local ignored = state.ignored_cache[e.path] == true
      local dimmed = hidden or ignored
      if state.show_hidden or not dimmed then
        result[#result + 1] = {
          path = e.path,
          name = e.name,
          depth = depth,
          is_dir = e.type == 'directory',
          dimmed = dimmed,
        }
        if e.type == 'directory' and state.expanded[e.path] then
          walk(e.path, depth + 1)
        end
      end
    end
  end
  walk(state.root, 0)
  return result
end

-- ===== Git status =====

-- Priority for parent directory aggregation: higher number wins.
-- Order (high → low): U > ? > M > A > R > C > D
local GIT_PRIORITY = { D = 1, C = 2, R = 3, A = 4, M = 5, ['?'] = 6, U = 7 }

local function parse_porcelain(out, root)
  local status, ignored, untracked_dirs = {}, {}, {}
  local i, len = 1, #out
  while i <= len do
    if i + 3 > len then break end
    local x = out:sub(i, i)
    local y = out:sub(i + 1, i + 1)
    local nul = out:find('\0', i + 3, true)
    if not nul then break end
    local path = out:sub(i + 3, nul - 1)
    if x == '!' and y == '!' then
      -- ignored dirs come with trailing slash; normalize for path matching
      path = path:gsub('/$', '')
      ignored[root .. '/' .. path] = true
      i = nul + 1
    else
      -- untracked dirs are reported as a single `?? path/` entry with no
      -- per-child entries; remember them so descendants can inherit `?`.
      if x == '?' and y == '?' and path:sub(-1) == '/' then
        path = path:sub(1, -2)
        untracked_dirs[root .. '/' .. path] = true
      end
      local code = (y ~= ' ' and y) or x
      status[root .. '/' .. path] = code
      -- rename/copy entries include an extra NUL-terminated old path
      if x == 'R' or x == 'C' then
        local nul2 = out:find('\0', nul + 1, true)
        i = (nul2 or nul) + 1
      else
        i = nul + 1
      end
    end
  end
  return status, ignored, untracked_dirs
end

local function propagate_git(map, root)
  local result = {}
  for path, code in pairs(map) do
    result[path] = code
    local parent = vim.fs.dirname(path)
    while parent and parent ~= root and #parent > #root do
      local existing = result[parent]
      local cur = (existing and GIT_PRIORITY[existing]) or 0
      local new = GIT_PRIORITY[code] or 0
      if new > cur then result[parent] = code end
      parent = vim.fs.dirname(parent)
    end
  end
  return result
end

-- Repo root discovery (cached). Walks up looking for .git so we can run
-- check-ignore with the *correct* git context per path, not state.root.
local repo_root_cache = {}
local function repo_root_for_dir(dir)
  if dir == nil then return nil end
  if repo_root_cache[dir] ~= nil then
    return repo_root_cache[dir] or nil
  end
  local check = dir
  while check and check ~= '' and check ~= '/' do
    if vim.uv.fs_stat(check .. '/.git') then
      repo_root_cache[dir] = check
      return check
    end
    check = vim.fs.dirname(check)
  end
  repo_root_cache[dir] = false
  return nil
end

local function find_repo_root(path)
  return repo_root_for_dir(vim.fs.dirname(path))
end

-- status: git status without --ignored. Cheap.
local git_running = false
local git_pending_done = nil
local function refresh_status(done)
  if git_running then
    git_pending_done = done
    return
  end
  git_running = true
  vim.system(
    { 'git', '-C', state.root, 'status', '--porcelain=v1', '-z' },
    {},
    vim.schedule_wrap(function(res)
      git_running = false
      if res.code == 0 and res.stdout and res.stdout ~= '' then
        -- porcelain paths are relative to the repo toplevel, not state.root.
        local repo = repo_root_for_dir(state.root) or state.root
        local status, _, untracked = parse_porcelain(res.stdout, repo)
        state.git_status = propagate_git(status, repo)
        state.untracked_dirs = untracked
      else
        state.git_status = {}
        state.untracked_dirs = {}
      end
      if done then done() end
      if git_pending_done then
        local d = git_pending_done
        git_pending_done = nil
        refresh_status(d)
      end
    end)
  )
end

-- ignored: git check-ignore --stdin for visible paths only. Lazy + cached.
-- Paths are grouped by their enclosing git repo and check-ignore is invoked
-- per-repo, so state.root being outside any repo doesn't poison the cache.
-- Output format with -v -z -n: <source>\0<linenum>\0<pattern>\0<pathname>\0
-- pattern == '' means non-matching (not ignored).
local check_running = false
local check_pending_paths = nil
local check_pending_done = nil
local function check_ignored_batch(paths, done)
  if check_running then
    check_pending_paths = paths
    check_pending_done = done
    return
  end

  local to_check = {}
  local seen = {}
  for _, p in ipairs(paths) do
    if state.ignored_cache[p] == nil and not seen[p] then
      seen[p] = true
      to_check[#to_check + 1] = p
    end
  end
  if #to_check == 0 then
    if done then done() end
    return
  end

  -- Group paths by enclosing repo. Paths outside any repo can be marked
  -- as not-ignored immediately (no .gitignore can possibly match them).
  local groups = {}
  local group_count = 0
  for _, p in ipairs(to_check) do
    local repo = find_repo_root(p)
    if repo then
      if not groups[repo] then
        groups[repo] = {}
        group_count = group_count + 1
      end
      groups[repo][#groups[repo] + 1] = p
    else
      state.ignored_cache[p] = false
    end
  end

  local function finish()
    check_running = false
    if done then done() end
    if check_pending_done then
      local pp, pd = check_pending_paths, check_pending_done
      check_pending_paths, check_pending_done = nil, nil
      check_ignored_batch(pp, pd)
    end
  end

  if group_count == 0 then
    finish()
    return
  end

  check_running = true
  local pending = group_count
  local function group_done()
    pending = pending - 1
    if pending == 0 then finish() end
  end

  for repo, repo_paths in pairs(groups) do
    vim.system(
      { 'git', '-C', repo, 'check-ignore', '--stdin', '-z', '-v', '-n' },
      { stdin = table.concat(repo_paths, '\0') .. '\0' },
      vim.schedule_wrap(function(res)
        if res.code == 0 or res.code == 1 then
          local out = res.stdout or ''
          local i = 1
          while i <= #out do
            local f = {}
            for j = 1, 4 do
              local nul = out:find('\0', i, true)
              if not nul then i = #out + 1; break end
              f[j] = out:sub(i, nul - 1)
              i = nul + 1
            end
            if #f == 4 then
              state.ignored_cache[f[4]] = (f[3] ~= '')
            end
          end
        else
          -- repo was found but check-ignore failed (rare): conservative false
          for _, p in ipairs(repo_paths) do
            state.ignored_cache[p] = false
          end
        end
        group_done()
      end)
    )
  end
end

local function collect_candidate_paths()
  local paths = {}
  local function walk(path)
    for name, ftype in vim.fs.dir(path) do
      if not IGNORE[name] then
        local child = path .. '/' .. name
        paths[#paths + 1] = child
        if ftype == 'directory' and state.expanded[child] then
          walk(child)
        end
      end
    end
  end
  walk(state.root)
  return paths
end

-- ===== Diagnostics =====

local function refresh_diag()
  local map = {}
  for _, d in ipairs(vim.diagnostic.get(nil)) do
    if d.bufnr and vim.api.nvim_buf_is_valid(d.bufnr) then
      local name = vim.api.nvim_buf_get_name(d.bufnr)
      if name ~= '' then
        name = vim.fs.normalize(name)
        if not map[name] or map[name] > d.severity then
          map[name] = d.severity
        end
      end
    end
  end
  -- snapshot file-level entries before propagating to parents (avoid pairs() mutation)
  local files = {}
  for path, sev in pairs(map) do
    files[#files + 1] = { path = path, sev = sev }
  end
  for _, f in ipairs(files) do
    local parent = vim.fs.dirname(f.path)
    while parent and parent ~= state.root and #parent > #state.root do
      if not map[parent] or map[parent] > f.sev then
        map[parent] = f.sev
      end
      parent = vim.fs.dirname(parent)
    end
  end
  state.diag = map
end

-- ===== Render =====

local GIT_HL = {
  M = 'DiffChange',
  A = 'DiffAdd',
  D = 'DiffDelete',
  R = 'DiffChange',
  C = 'DiffChange',
  U = 'ErrorMsg',
  ['?'] = 'DiagnosticError',
}

local DIAG_CHAR = { [1] = 'E', [2] = 'W', [3] = 'I', [4] = 'H' }
local DIAG_HL = {
  [1] = 'DiagnosticError',
  [2] = 'DiagnosticWarn',
  [3] = 'DiagnosticInfo',
  [4] = 'DiagnosticHint',
}

-- Git porcelain reports untracked dirs as a single `?? dir/` entry without
-- listing children, so descendants need to inherit `?` from the ancestor.
local function effective_git(path)
  local s = state.git_status[path]
  if s then return s end
  local p = vim.fs.dirname(path)
  while p and #p > #state.root do
    if state.untracked_dirs[p] then return '?' end
    p = vim.fs.dirname(p)
  end
  return nil
end

local function name_hl(e)
  if e.dimmed then return 'Comment' end
  if e.is_dir then return 'Directory' end
  return nil
end

-- Lazily define a hl group for a hex color and return its name.
local color_hl_cache = {}
local function hl_for_color(color)
  local cached = color_hl_cache[color]
  if cached then return cached end
  local name = 'SidetreeIconC' .. color:gsub('#', ''):upper()
  vim.api.nvim_set_hl(0, name, { fg = color, default = true })
  color_hl_cache[color] = name
  return name
end

render = function()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  state.entries = build_entries()

  local lines = {}
  local meta = {}
  for _, e in ipairs(state.entries) do
    -- Expanded dirs hide their propagated markers since the contributing
    -- child entry is already visible directly underneath.
    local hide_markers = e.is_dir and state.expanded[e.path]
    local git = (not hide_markers and effective_git(e.path)) or ' '
    local sev = not hide_markers and state.diag[e.path] or nil
    local diag = (sev and DIAG_CHAR[sev]) or ' '
    local indent = string.rep('  ', e.depth)
    local icon, color
    if e.is_dir then
      icon = icons.for_dir(state.expanded[e.path])
    else
      icon, color = icons.for_file(e.name)
      icon = icon or icons.default_file
    end
    local name = e.is_dir and (e.name .. '/') or e.name
    local prefix = git .. ' ' .. diag .. ' ' .. indent
    local icon_part = icon .. ' '
    local line = prefix .. icon_part .. name
    lines[#lines + 1] = line
    meta[#meta + 1] = {
      icon_start = #prefix,
      icon_end   = #prefix + #icon,
      name_start = #prefix + #icon_part,
      line_len   = #line,
      color      = color,
    }
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  for i, e in ipairs(state.entries) do
    local row = i - 1
    local m = meta[i]
    local hide_markers = e.is_dir and state.expanded[e.path]
    local git = not hide_markers and effective_git(e.path) or nil
    if git then
      vim.api.nvim_buf_set_extmark(state.buf, ns, row, 0, {
        end_col = 1,
        hl_group = GIT_HL[git] or 'Normal',
      })
    end
    local sev = not hide_markers and state.diag[e.path] or nil
    if sev then
      vim.api.nvim_buf_set_extmark(state.buf, ns, row, 2, {
        end_col = 3,
        hl_group = DIAG_HL[sev],
      })
    end
    -- Icon color: dimmed > directory > language color
    local icon_hl
    if e.dimmed then
      icon_hl = 'Comment'
    elseif e.is_dir then
      icon_hl = 'Directory'
    elseif m.color then
      icon_hl = hl_for_color(m.color)
    end
    if icon_hl then
      vim.api.nvim_buf_set_extmark(state.buf, ns, row, m.icon_start, {
        end_col = m.icon_end,
        hl_group = icon_hl,
      })
    end
    -- Name color: dimmed (Comment) or dir (Directory), else uncolored
    local n_hl = name_hl(e)
    if n_hl then
      vim.api.nvim_buf_set_extmark(state.buf, ns, row, m.name_start, {
        end_col = m.line_len,
        hl_group = n_hl,
      })
    end
  end
  vim.bo[state.buf].modifiable = false

  if state.after_render then
    local cb = state.after_render
    state.after_render = nil
    cb()
  end
end

-- ===== Refresh =====

-- Run status and check-ignore in parallel; render once both complete.
-- Each is reentrant-safe so rapid M.refresh calls coalesce.

function M.refresh()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  refresh_diag()

  local pending = 2
  local function tick()
    pending = pending - 1
    if pending == 0 then render() end
  end
  refresh_status(tick)
  check_ignored_batch(collect_candidate_paths(), tick)
end

-- ===== Actions =====

local function entry_under_cursor()
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then return nil end
  local row = vim.api.nvim_win_get_cursor(state.win)[1]
  return state.entries[row]
end

local function find_target_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if w ~= state.win then
      local cfg = vim.api.nvim_win_get_config(w)
      if cfg.relative == '' then return w end
    end
  end
  return nil
end

local function go_up()
  local parent = vim.fs.dirname(state.root)
  if not parent or parent == state.root then return end
  local old_root = state.root
  state.expanded[old_root] = true  -- keep the previous view in context
  state.root = parent
  -- git context changes; the new root might not be in any repo.
  -- Do NOT clear ignored_cache: cached values for paths under sub-repos
  -- remain correct, and re-running check-ignore at a non-repo root would
  -- incorrectly mark them as not ignored.
  state.git_status = {}
  -- After re-render, put cursor on the previous root entry
  state.after_render = function()
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then return end
    for i, ent in ipairs(state.entries) do
      if ent.path == old_root then
        pcall(vim.api.nvim_win_set_cursor, state.win, { i, 0 })
        return
      end
    end
  end
  M.refresh()
end

local function open_or_toggle()
  local e = entry_under_cursor()
  if not e then return end
  if e.is_dir then
    if state.expanded[e.path] then
      state.expanded[e.path] = nil
    else
      state.expanded[e.path] = true
    end
    render()
    -- Newly-visible paths may not be in the ignored cache yet; fill them in
    -- async and re-render so .gitignore'd entries get filtered out.
    check_ignored_batch(collect_candidate_paths(), render)
  else
    local target = find_target_win()
    if target then
      vim.api.nvim_set_current_win(target)
      vim.cmd.edit(vim.fn.fnameescape(e.path))
    else
      vim.cmd('rightbelow vsplit ' .. vim.fn.fnameescape(e.path))
    end
  end
end

-- ===== File operations =====

local function notify_err(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

local function resolve_path(input, anchor)
  -- absolute path used as-is; relative is resolved against anchor (old path dir)
  if input:sub(1, 1) == '/' then
    return vim.fs.normalize(input)
  end
  return vim.fs.normalize(vim.fs.dirname(anchor) .. '/' .. input)
end

-- Update buffer names after a path is renamed/moved. Handles both a single
-- file rename and a directory move (children buffers get their names rewritten).
local function sync_buffer_rename(old_path, new_path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == '' then
        -- skip unnamed
      elseif name == old_path then
        vim.api.nvim_buf_set_name(buf, new_path)
        if not vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, function() vim.cmd('silent! edit') end)
        end
      elseif name:sub(1, #old_path + 1) == old_path .. '/' then
        local updated = new_path .. name:sub(#old_path + 1)
        vim.api.nvim_buf_set_name(buf, updated)
        if not vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, function() vim.cmd('silent! edit') end)
        end
      end
    end
  end
end

local function close_buffers_under(path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == path or (name ~= '' and name:sub(1, #path + 1) == path .. '/') then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end
end

-- Move/rename: same fs_rename op handles both (changing the basename = rename,
-- changing the dirname = move, both = both).
local function move_entry(e)
  vim.ui.input({ prompt = 'Move to: ', default = e.path, completion = 'file' }, function(input)
    if not input or input == '' or input == e.path then return end
    local dst = resolve_path(input, e.path)
    if vim.uv.fs_stat(dst) then
      notify_err('Target exists: ' .. dst)
      return
    end
    -- ensure destination directory exists
    vim.fn.mkdir(vim.fs.dirname(dst), 'p')
    local ok, err = vim.uv.fs_rename(e.path, dst)
    if not ok then
      notify_err('Move failed: ' .. tostring(err))
      return
    end
    sync_buffer_rename(e.path, dst)
    -- previous cache entry is stale (path no longer exists)
    state.ignored_cache[e.path] = nil
    M.refresh()
  end)
end

local function delete_entry(e)
  local label = e.is_dir and (e.path .. ' (recursively)') or e.path
  local choice = vim.fn.confirm('Delete ' .. label .. '?', '&Yes\n&No', 2)
  if choice ~= 1 then return end

  if e.is_dir then
    local res = vim.system({ 'rm', '-rf', e.path }):wait()
    if res.code ~= 0 then
      notify_err('Delete failed: ' .. (res.stderr or ''))
      return
    end
  else
    local ok, err = vim.uv.fs_unlink(e.path)
    if not ok then
      notify_err('Delete failed: ' .. tostring(err))
      return
    end
  end
  close_buffers_under(e.path)
  state.ignored_cache[e.path] = nil
  state.expanded[e.path] = nil
  M.refresh()
end

local function copy_entry(e)
  vim.ui.input({ prompt = 'Copy to: ', default = e.path, completion = 'file' }, function(input)
    if not input or input == '' or input == e.path then return end
    local dst = resolve_path(input, e.path)
    if vim.uv.fs_stat(dst) then
      notify_err('Target exists: ' .. dst)
      return
    end
    vim.fn.mkdir(vim.fs.dirname(dst), 'p')
    if e.is_dir then
      vim.system({ 'cp', '-R', e.path, dst }, {}, vim.schedule_wrap(function(res)
        if res.code ~= 0 then
          notify_err('Copy failed: ' .. (res.stderr or ''))
        end
        M.refresh()
      end))
    else
      local ok, err = vim.uv.fs_copyfile(e.path, dst)
      if not ok then
        notify_err('Copy failed: ' .. tostring(err))
        return
      end
      M.refresh()
    end
  end)
end

-- Create a new file or directory inside target_dir. Trailing '/' on the
-- input creates a directory; intermediate dirs are mkdir -p'd as needed.
local function add_in(target_dir)
  vim.ui.input({ prompt = 'New (end with / for dir): ' .. target_dir .. '/' }, function(name)
    if not name or name == '' then return end
    local is_dir = name:sub(-1) == '/'
    local dst = vim.fs.normalize(target_dir .. '/' .. name)
    if vim.uv.fs_stat(dst) then
      notify_err('Already exists: ' .. dst)
      return
    end
    if is_dir then
      vim.fn.mkdir(dst, 'p')
    else
      vim.fn.mkdir(vim.fs.dirname(dst), 'p')
      local fd, err = vim.uv.fs_open(dst, 'w', 420)
      if not fd then
        notify_err('Create failed: ' .. tostring(err))
        return
      end
      vim.uv.fs_close(fd)
    end
    -- Expand all ancestors up to target_dir so the new entry is visible
    local p = vim.fs.dirname(dst)
    while p and #p >= #target_dir do
      state.expanded[p] = true
      if p == target_dir then break end
      p = vim.fs.dirname(p)
    end
    -- Jump cursor to the new entry after refresh
    state.after_render = function()
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then return end
      for i, ent in ipairs(state.entries) do
        if ent.path == dst then
          pcall(vim.api.nvim_win_set_cursor, state.win, { i, 0 })
          return
        end
      end
    end
    M.refresh()
  end)
end

-- ===== Window/buffer =====

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'sidetree'
  pcall(vim.api.nvim_buf_set_name, buf, 'sidetree://tree')

  local opts = { buffer = buf, silent = true, nowait = true }
  local with_entry = function(fn)
    return function()
      local e = entry_under_cursor()
      if e then fn(e) end
    end
  end
  vim.keymap.set('n', '<CR>', open_or_toggle, opts)
  vim.keymap.set('n', '<BS>', go_up, opts)
  vim.keymap.set('n', 'R', M.refresh, opts)
  vim.keymap.set('n', 'H', function() M.toggle_hidden() end, opts)
  vim.keymap.set('n', 'm', with_entry(move_entry), opts)
  vim.keymap.set('n', 'd', with_entry(delete_entry), opts)
  vim.keymap.set('n', 'c', with_entry(copy_entry), opts)
  vim.keymap.set('n', 'a', function()
    local e = entry_under_cursor()
    -- file under cursor → create in its parent; dir → create inside it; nothing → root
    local target = (e and (e.is_dir and e.path or vim.fs.dirname(e.path))) or state.root
    add_in(target)
  end, opts)
  vim.keymap.set('n', 'q', function() M.close() end, opts)

  return buf
end

local function open_window(buf)
  vim.cmd('topleft 30vsplit')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].wrap = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
  vim.wo[win].cursorline = true
  vim.wo[win].winfixwidth = true
  vim.wo[win].list = false
  return win
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end
  state.root = vim.fs.normalize(vim.fn.getcwd())
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = create_buffer()
  end
  state.win = open_window(state.buf)
  M.refresh()
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    if vim.api.nvim_get_current_win() == state.win then
      M.close()
    else
      vim.api.nvim_set_current_win(state.win)
    end
  else
    M.open()
  end
end

function M.toggle_hidden()
  state.show_hidden = not state.show_hidden
  render()
end

function M.debug()
  return {
    root = state.root,
    show_hidden = state.show_hidden,
    diag = state.diag,
    git_status = state.git_status,
    ignored_cache = state.ignored_cache,
    entry_count = #state.entries,
  }
end

-- ===== Setup =====

function M.setup()
  local grp = vim.api.nvim_create_augroup('sidetree', { clear = true })

  vim.keymap.set('n', '<C-e>', M.toggle, { silent = true, desc = 'Toggle sidetree' })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = grp,
    callback = function()
      -- Skip auto-open when nvim was launched with file arguments
      if vim.fn.argc() > 0 then return end
      vim.schedule(M.open)
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufWritePost', 'FocusGained' }, {
    group = grp,
    callback = function(ev)
      -- .gitignore (or .git/info/exclude) edit invalidates the cache
      if ev.event == 'BufWritePost' and ev.file then
        local base = vim.fs.basename(ev.file)
        if base == '.gitignore' or ev.file:find('%.git/info/exclude$') then
          state.ignored_cache = {}
        end
      end
      M.refresh()
    end,
  })

  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = grp,
    callback = function() M.refresh() end,
  })

  -- If the user :q's the last non-sidetree regular window, close sidetree too
  -- so the quit propagates and nvim exits (saves them from typing :qa).
  vim.api.nvim_create_autocmd('QuitPre', {
    group = grp,
    callback = function()
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then return end
      local cur = vim.api.nvim_get_current_win()
      if cur == state.win then return end
      if vim.api.nvim_win_get_config(cur).relative ~= '' then return end

      local other = 0
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if w ~= state.win and vim.api.nvim_win_get_config(w).relative == '' then
          other = other + 1
        end
      end
      if other == 1 then
        pcall(vim.api.nvim_win_close, state.win, true)
        state.win = nil
      end
    end,
  })
end

return M
