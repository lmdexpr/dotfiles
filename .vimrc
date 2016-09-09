filetype off

set fileencodings=utf-8,euc-jp,sjis

"----------------------Color Setting Start----------------------------------
set t_Co=256
set number
syntax enable

colorscheme hybrid
set background=dark
highlight Normal ctermbg=none

let g:deoplete#enable_at_startup = 1
"----------------------Color Setting Complete-------------------------------

"----------------------Indent Setting Start---------------------------------
set tabstop=2
set shiftwidth=2

set expandtab

set nocindent
autocmd FileType c setlocal cindent

set backspace=indent,eol,start
set wrapscan
set showmatch
set wildmenu
set formatoptions+=mM
"----------------------Indent Setting Complete------------------------------

"----------------------NeoBundle Setting Start------------------------------
set nocompatible					"beiMproved
filetype off

if has( 'vim_starting' )
    set runtimepath+=~/.vim/bundle/neobundle.vim
    call neobundle#begin(expand('~/.vim/bundle'))
endif

" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'			" NeoBundle
NeoBundle 'scrooloose/nerdtree'				" NerdTree
NeoBundle 'Shougo/unite.vim'			  	" Unite		filer&luncher
NeoBundle 'Shougo/unite-outline'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'scrooloose/syntastic'

NeoBundle 'Shougo/vimproc',{
      \ 'build' : {
      \ 'unix' : 'make -f make_unix.mak',
      \},
      \}

NeoBundle 'Shougo/vinarise.vim'

NeoBundle 'vim-scripts/errormarker.vim'

"Haskell
NeoBundle 'dag/vim2hs'
"NeoBundle 'eagletmt/ghcmod-vim'
NeoBundle 'eagletmt/unite-haddock'
NeoBundle 'ujihisa/neco-ghc'
NeoBundle 'kana/vim-filetype-haskell'
NeoBundle 'pbrisbin/html-template-syntax'
"NeoBundle 'nbouscal/vim-stylish-haskell'

"template
NeoBundle 'thinca/vim-template'

"markdown
NeoBundle 'tpope/vim-markdown'

"scheme
NeoBundle 'aharisu/vim_goshrepl'
"NeoBundle 'aharisu/vim-gdev'
"NeoBundle 'amdt/vim-niji'

"Scala
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'gre/play2vim'

"ML
"NeoBundle 'cohama/the-ocamlspot.vim'
NeoBundle 'kongo2002/fsharp-vim'

"HTML,CSS,JS
NeoBundle 'mattn/emmet-vim'
NeoBundle 'kchmck/vim-coffee-script'

"NeoBundle 'https://gitbucket.org/kovisoft/slimv'

call neobundle#end()

"-----------------------NeoBundle Setting Complete--------------------------

"-----------------------NerdTree Setting Start------------------------------
let file_name = expand("%:p")

if has('vim_starting') && file_name == ""
  autocmd VimEnter * call ExecuteNERDTree()
endif

function! ExecuteNERDTree()
  if !exists('g:nerdtatus')
    execute 'NERDTree ./'
    let g:windowWidth = winwidth(winnr())
    let g:nerdtreebuf = bufnr('')
    let g:nerdstatus = 1

  elseif g:nerdstatus == 1
    execute 'wincmd t'
    execute 'vertical resize' 0
    execute 'wincmd p'
    let g:nerdstatus = 2

  elseif g:nerdstatus == 2
    execute 'wincmd t'
    execute 'vertical resize' g:windowWidth
    let g:nerdstatus = 1

  endif
endfunction

noremap <c-e> :<c-u>:call ExecuteNERDTree()<cr>
"-----------------------NerdTree Setting Complete---------------------------

"-----------------------NeoSnippet Setting Start----------------------------
"Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable_or_jumpable() ? 
"      \"\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \"\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

let g:neosnippet#enable_snipmate_compatibility = 1
let g:neocomplcache_enable_at_startup = 1
let g:neosnippet#snippets_directory = '~/.vim/bundle/neosnippet-snippets/neosnippets, ~/.vim/snippets'
"-----------------------NeoSnippet Setting Complete-------------------------

"-----------------------NeoComplcache Setting Start-------------------------
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ?    neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backwordchar.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#close_popup()
inoremap <expr><C-e> neocomplcache#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplcache#close_popup() : "\<Space>"

" For cursor moving in insert mode(Notrecommended)
"inoremap <expr><Left> neocomplcache#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
"inoremap <expr><Up> neocomplcache#close_popup() . "\<Up>"
"inoremap <expr><Down> neocomplcache#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplcache_enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplcache_enable_insert_char_pre =1

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setloca omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.php = '[^.\t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c ='[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp ='[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
"-----------------------NeoComplcache Setting Complete----------------------

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

"-----------------------Marker Setting Start--------------------------------
let g:errormarker_errortext    = '!!'
let g:errormarker_warningtext  = '??'
let g:errormarker_errorgroup   = 'Error'
let g:errormarker_warninggroup = 'ToDo'
"-----------------------Marker Setting Complete-----------------------------

"-----------------------Annot Setting Start---------------------------------
function! OCamlType()
  let col  = col('.')
  let line = line('.')
  let file = expand("%:p:r")
  echo system("annot -n -type ".line." ".col." ".file.".annot")
endfunction

map ,t :call OCamlType()<return>
"-----------------------Annot Setting Complete------------------------------

let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

let g:CoqIDEDefaultKeyMap=1

let g:haskell_conceal = 0 
"let g:haskell_conceal_enumerations = 0

let g:neocomplcache_keyword_patterns['gosh-repl'] = 
      \"[[:alpha:]+*/@$_=.!?-][[:alnum:]+*/@$_:=.!?-]*"
let g:gosh_buffer_direction = 'v'

vmap <CR> <Plug>(gosh_repl_send_block)

vnoremap <silent> <C-p> "0p<CR>

vnoremap <silent> <C-g> :CoqGoto<CR>

" merlin
"let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
"execute "set rtp+=" . g:opamshare . "/merlin/vim"
"execute "helptags " . g:opamshare . "/merlin/vim/doc"

filetype plugin indent on
NeoBundleCheck
