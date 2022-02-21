"**********************************************************************************
"
" init.vim
"
"**********************************************************************************

let mapleader=" "
let maplocalleader = ","
set nocompatible              " be iMproved, required
filetype off                  " required

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.nvim/plugged')


Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'git://git.wincent.com/command-t.git'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'mboughaba/i3config.vim'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'lervag/vimtex'
Plug 'ebranlard/vim-matlab-behave'
Plug 'justinmk/vim-syntax-extra'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'mkitt/tabline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'dracula/vim', {'as':'dracula'}
Plug 'ap/vim-css-color'
Plug 'jreybert/vimagit'
Plug 'vim-python/python-syntax'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tpope/vim-surround'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-sleuth'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Yggdroot/indentLine'
Plug 'puremourning/vimspector'
Plug 'kaicataldo/material.vim', { 'branch': 'main' } " only used for the airline theme

" Load vim-devicons last
Plug 'ryanoasis/vim-devicons'

" Initialize plugin system
call plug#end()


" Set hybrid line numbers
set relativenumber
set number

syntax on
set encoding=UTF-8

set mouse=a
set tabstop=4
set shiftwidth=4

" Reload file when changed externally
set autoread

" Don't conceal in isert and normal mode
let g:indentLine_concealcursor = ''

" vimtex stuffs
let g:vimtex_view_general_viewer = 'evince'
let g:tex_flavor = 'latex'

" Markdown mappings
autocmd FileType markdown nnoremap <Leader>p :Pandoc pdf <CR>
autocmd FileType markdown nnoremap <Leader>b :Pandoc beamer <CR>
autocmd FileType markdown nnoremap <Leader>h :! pandoc % --toc -s --mathjax -o %:r.html <CR>


" ------------------------------------------------------------------------
" Colors
" ------------------------------------------------------------------------
execute "set t_8f=\e[38;2;%lu;%lu;%lum"
execute "set t_8b=\e[48;2;%lu;%lu;%lum"

" Load custom variant of material theme
source $HOME/.config/nvim/colors/material.vim

set termguicolors

let g:material_theme_style='default'
let g:airline_theme='material'
let g:material_terminal_italics = 1
set background=dark
colorscheme material

"let g:airline_theme='dracula'
"colorscheme dracula

hi Normal guibg=NONE ctermbg=NONE

" Tab switching
no <C-j> <C-w>j | "Switching Below tab
no <C-k> <C-w>k | "Switching Above tab
no <C-l> <C-w>l | "Switching Right tab
no <C-h> <C-w>h | "Switching Left tab


" Remove pipe symbols from splits
set fillchars+=vert:\ 

" Splits and tabs
set splitbelow splitright

" Python syntax
let g:python_highlight_all = 1
let g:python_highlight_space_errors = 0


" ------------------------------------------------------------------------
" Conquerer of Completion shizz
" ------------------------------------------------------------------------

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

 " Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif


" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add `:Header` command to switch between header and source
command! -nargs=0 Header :call 	CocAction('runCommand', 'clangd.switchSourceHeader')

" Coc explorer shizz
let g:coc_explorer_global_presets = {
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   }
\}

nnoremap <leader>ef :CocCommand explorer --preset floating<CR>
nnoremap <leader>e :CocCommand explorer<CR>

" Fzf
nnoremap <C-p> :GFiles<CR>

" Fugitive mappings
nmap <leader>gs :G<CR>
nmap <leader>gj :diffget //3<CR>
nmap <leader>gf :diffget //2<CR>
set diffopt=vertical

" GitGutter
set updatetime=100
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1

let g:gitgutter_sign_added = '++'
let g:gitgutter_sign_removed = '--'

" Better whitespace config
let g:strip_whitespace_on_save = 0


" ------------------------------------------------------------------------
" Vim spector
" ------------------------------------------------------------------------

nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>

nmap <leader>drc <Plug>VimspectorRunToCursor
nmap <leader>dbp <Plug>VimspectorToggleBreakpoint
nmap <leader>dcbp <Plug>VimspectorToggleConditionalBreakpoint

nmap <leader>dl <Plug>VimSpectorStepInto
nmap <leader>dj <Plug>VimSpectorStepOver
nmap <leader>dk <Plug>VimSpectorStepOut
nmap <leader>d_ <Plug>VimSpectorRestart

nnoremap <leader>d<space> :call vimspector#Continue()<CR>
