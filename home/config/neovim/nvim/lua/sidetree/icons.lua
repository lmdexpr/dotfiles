-- File icons are delegated to nvim-web-devicons so the mapping stays in sync
-- with the rest of the UI (lualine, bufferline). Requires a Nerd-Font-patched
-- font. Directory glyphs are kept local since devicons has no open/closed
-- folder concept.

local M = {}

-- Folder glyphs use \xXX byte escapes so they survive any encoding round-trip.
-- Codepoints noted in comments; verified against Nerd Font v3 cheatsheet.
M.default_file = '\xee\xa9\xbb'  -- U+EA7B  cod-file
M.dir_closed   = '\xee\xaa\x83'  -- U+EA83  cod-folder
M.dir_open     = '\xee\xab\xb7'  -- U+EAF7  cod-folder-opened

-- Lazily resolved so load order (sidetree.setup runs before lazy plugins are
-- triggered) doesn't matter; lazy.nvim's loader pulls the plugin on require.
local devicons
local function get_devicons()
  if devicons == nil then
    local ok, mod = pcall(require, 'nvim-web-devicons')
    devicons = ok and mod or false
  end
  return devicons or nil
end

-- ===== Lookups =====

-- Returns (icon, hex_color). Falls back to the local default glyph when
-- nvim-web-devicons is unavailable so the tree still renders.
function M.for_file(name)
  local dev = get_devicons()
  if not dev then return M.default_file, nil end
  local ext = name:match('%.([^.]+)$')
  return dev.get_icon_color(name, ext, { default = true })
end

function M.for_dir(open)
  return open and M.dir_open or M.dir_closed
end

return M
