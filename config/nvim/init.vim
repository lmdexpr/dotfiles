filetype off

set mouse=a

set fileencodings=utf-8,euc-jp,sjis

"----------------------Color Setting Start----------------------------------
set termguicolors
set t_Co=256
set t_ut=
set number
syntax enable

highlight Normal ctermbg=none
"----------------------Color Setting Complete-------------------------------

"----------------------Indent Setting Start---------------------------------
set tabstop=2
set shiftwidth=2

augroup vimrc-filetype
  autocmd!
  autocmd BufNewFile,BufRead *.php set filetype=php
  autocmd FileType php setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
augroup END

set expandtab

set nocindent
autocmd FileType c setlocal cindent

set backspace=indent,eol,start
set wrapscan
set showmatch
set wildmenu
set formatoptions+=mM
"----------------------Indent Setting Complete------------------------------

let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/opt/homebrew/bin/python3'

"----------------------Dein Setting Start-----------------------------------
if &compatible
	set nocompatible
endif

" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END<Paste>

" dein.vimのディレクトリ
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" なければgit clone
if !isdirectory(s:dein_repo_dir)
	execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath^=' . s:dein_repo_dir

if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)

	let s:toml = '~/.config/nvim/dein.toml'
	let s:lazy_toml = '~/.config/nvim/dein_lazy.toml'
	call dein#load_toml(s:toml, {'lazy': 0})
	call dein#load_toml(s:lazy_toml, {'lazy': 1})

	call dein#end()
	call dein#save_state()
endif

" プラグインの追加・削除やtomlファイルの設定を変更した後は
" 適宜 call dein#update や call dein#clear_stateを呼んでください。
" そもそもキャッシュしなくて良いならload_state/save_stateを呼ばないようにしてください。

" その他インストールしていないものはこちらに入れる
if dein#check_install()
  call dein#install()
endif
"----------------------Dein Setting Complete-------------------------------

set completeopt-=preview

" for OCaml
let s:opam_share_dir = system("opam var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"

let s:opam_bin_dir = system("opam var bin")
let s:opam_bin_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp+=" . s:opam_bin_dir . "/ocamlformat"

" no highlight
nmap <silent> <Esc><Esc> :<C-u>nohlsearch<CR><Esc>

filetype plugin indent on

augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.require('statusline').active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.require('statusline').inactive()
augroup END
