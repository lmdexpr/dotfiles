-- Nerd Font icon mapping. Requires a Nerd-Font-patched font.
-- Glyph values use \xXX byte escapes so they survive any encoding round-trip.
-- Codepoints noted in comments; verified against Nerd Font v3 cheatsheet.

local M = {}

-- Exact filename matches (checked first)
M.by_name = {
  ['Dockerfile']    = '\xf3\xb0\xa1\xa8',  -- U+F0868 md-docker
  ['Makefile']      = '\xee\x99\xb3',      -- U+E673  seti-makefile
  ['LICENSE']       = '\xee\xac\xa3',      -- U+EB23  cod-law
  ['README']        = '\xee\x9c\xbe',      -- U+E73E  dev-markdown
  ['README.md']     = '\xee\x9c\xbe',      -- U+E73E
  ['.gitignore']    = '\xee\x99\x9d',      -- U+E65D  seti-gitignore
  ['.gitconfig']    = '\xee\x9c\x82',      -- U+E702  seti-git
  ['.gitmodules']   = '\xee\x9c\x82',      -- U+E702
  ['flake.nix']     = '\xef\x8c\x93',      -- U+F313  linux-nixos
  ['flake.lock']    = '\xee\xa9\xb5',      -- U+EA75  cod-lock
  ['shell.nix']     = '\xef\x8c\x93',      -- U+F313
  ['.envrc']        = '\xef\x80\x93',      -- U+F013  fa-cog
  ['.editorconfig'] = '\xee\x99\x92',      -- U+E652  seti-editorconfig
  ['dune']          = '\xee\x99\xba',      -- U+E67A  seti-ocaml (camel)
  ['dune-project']  = '\xee\x99\xba',      -- U+E67A
}

-- Multi-part suffix matches (longest first). Checked before by_ext.
M.by_suffix = {
  { '.res.mjs', '\xee\x9e\xba' },  -- U+E7BA dev-react (rescript compiled)
  { '.bs.js',   '\xee\x9e\xba' },  -- U+E7BA (legacy bucklescript output)
}

-- Single extension (lowercase, no dot)
M.by_ext = {
  -- code
  lua  = '\xee\x98\xa0',  -- U+E620
  nix  = '\xef\x8c\x93',  -- U+F313
  rs   = '\xee\x9e\xa8',  -- U+E7A8
  go   = '\xee\x98\xa7',  -- U+E627
  ts   = '\xee\x98\xa8',  -- U+E628
  tsx  = '\xee\x98\xa8',  -- U+E628
  js   = '\xee\x98\x8c',  -- U+E60C
  jsx  = '\xee\x98\x8c',  -- U+E60C
  py   = '\xee\x98\x86',  -- U+E606
  rb   = '\xee\x88\x9e',  -- U+E21E
  sh   = '\xee\xaf\x8a',  -- U+EBCA
  zsh  = '\xee\xaf\x8a',  -- U+EBCA
  bash = '\xee\xaf\x8a',  -- U+EBCA
  vim  = '\xee\x98\xab',  -- U+E62B
  hs   = '\xee\x9d\xb7',  -- U+E777
  ml   = '\xee\x99\xba',  -- U+E67A  seti-ocaml (camel)
  mli  = '\xee\x99\xba',  -- U+E67A
  res  = '\xee\x9e\xba',  -- U+E7BA  dev-react (rescript)
  resi = '\xee\x9e\xba',  -- U+E7BA
  c    = '\xee\x98\x9e',  -- U+E61E
  h    = '\xee\x98\x9e',  -- U+E61E
  cpp  = '\xee\x98\x9d',  -- U+E61D
  hpp  = '\xee\x98\x9d',  -- U+E61D
  java = '\xee\x89\x96',  -- U+E256
  -- markup / data
  md   = '\xee\x9c\xbe',  -- U+E73E
  json = '\xee\x98\x8b',  -- U+E60B
  yaml = '\xee\x9a\xa8',  -- U+E6A8
  yml  = '\xee\x9a\xa8',  -- U+E6A8
  toml = '\xee\x9a\xb2',  -- U+E6B2
  xml  = '\xee\x9e\x96',  -- U+E796
  html = '\xee\x98\x8e',  -- U+E60E
  css  = '\xee\x98\x94',  -- U+E614
  scss = '\xee\x98\x94',  -- U+E614
  -- images
  png  = '\xee\x98\x8d',  -- U+E60D
  jpg  = '\xee\x98\x8d',
  jpeg = '\xee\x98\x8d',
  gif  = '\xee\x98\x8d',
  svg  = '\xee\x9a\x98',  -- U+E698
  -- docs
  pdf  = '\xee\xab\xab',  -- U+EAEB
  txt  = '\xef\x83\xb6',  -- U+F0F6
  -- archives
  zip  = '\xee\xac\xac',  -- U+EB2C
  tar  = '\xee\xac\xac',
  gz   = '\xee\xac\xac',
}

M.default_file = '\xee\xa9\xbb'  -- U+EA7B
M.dir_closed   = '\xee\xaa\x83'  -- U+EA83
M.dir_open     = '\xee\xab\xb7'  -- U+EAF7

-- ===== Colors (per-language, devicons-inspired) =====

M.color_by_name = {
  ['Dockerfile']   = '#458ee6',
  ['Makefile']     = '#427819',
  ['LICENSE']      = '#cbcb41',
  ['flake.nix']    = '#7ebae4',
  ['flake.lock']   = '#7ebae4',
  ['shell.nix']    = '#7ebae4',
  ['dune']         = '#e8743b',
  ['dune-project'] = '#e8743b',
}

M.color_by_ext = {
  lua  = '#51a0cf',
  nix  = '#7ebae4',
  rs   = '#dea584',
  go   = '#519aba',
  ts   = '#519aba',
  tsx  = '#519aba',
  js   = '#cbcb41',
  jsx  = '#519aba',
  py   = '#ffbc03',
  rb   = '#cc342d',
  sh   = '#89e051',
  zsh  = '#89e051',
  bash = '#89e051',
  vim  = '#019833',
  hs   = '#a074c4',
  ml   = '#e8743b',  -- OCaml camel tone
  mli  = '#e8743b',
  res  = '#e6484f',  -- ReScript brand red
  resi = '#e6484f',
  c    = '#599eff',
  h    = '#a074c4',
  cpp  = '#519aba',
  hpp  = '#a074c4',
  java = '#cc3e44',
  md   = '#519aba',
  json = '#cbcb41',
  yaml = '#6d8086',
  yml  = '#6d8086',
  toml = '#6d8086',
  xml  = '#e37933',
  html = '#e34c26',
  css  = '#42a5f5',
  scss = '#f55385',
  png  = '#a074c4',
  jpg  = '#a074c4',
  jpeg = '#a074c4',
  gif  = '#a074c4',
  svg  = '#ffb13b',
  pdf  = '#b30b00',
  txt  = '#6d8086',
  zip  = '#eca517',
  tar  = '#eca517',
  gz   = '#eca517',
}

M.color_by_suffix = {
  { '.res.mjs', '#e6484f' },
  { '.bs.js',   '#e6484f' },
}

-- ===== Lookups =====

function M.for_file(name)
  local g = M.by_name[name]
  if g then return g, M.color_by_name[name] end
  for _, e in ipairs(M.by_suffix) do
    if name:sub(-#e[1]) == e[1] then
      for _, ce in ipairs(M.color_by_suffix) do
        if ce[1] == e[1] then return e[2], ce[2] end
      end
      return e[2], nil
    end
  end
  local ext = name:match('%.([^.]+)$')
  if ext then
    ext = ext:lower()
    return M.by_ext[ext], M.color_by_ext[ext]
  end
end

function M.for_dir(open)
  return open and M.dir_open or M.dir_closed
end

return M
