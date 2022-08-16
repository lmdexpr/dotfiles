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
let g:python3_host_prog = '/usr/local/bin/python3'

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

"-----------------------Tab Page Setting Start------------------------------
" Anywhere SID.
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
function! s:my_tabline()  "{{{
  let s = ''
  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
    let no = i  " display 0-origin tabpagenr.
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
    let title = fnamemodify(bufname(bufnr), ':t')
    let title = '[' . title . ']'
    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor
  let s .= '%#TabLineFill#%T%=%#TabLine#'
  return s
endfunction "}}}
let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'

for n in range(1, 9)
  execute 'nnoremap <silent> g'.n ':<C-u>tabnext'.n.'<CR>'
endfor

nmap <silent> gc :tabnew<CR>
"-----------------------Tab Page Setting Complete---------------------------

" return buffer
nmap <silent> gb :bprevious<CR>

set completeopt-=preview

" for OCaml
let s:opam_share_dir = system("opam var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"

let s:opam_bin_dir = system("opam var bin")
let s:opam_bin_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

execute "set rtp+=" . s:opam_bin_dir . "/ocamlformat"

filetype plugin indent on
