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
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
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
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

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
set expandtab

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
autocmd FileType markdown nnoremap <Leader>h :! pandoc --toc --standalone --mathjax=http://cdn.mathjax.org/mathjax/latest/MathJax.js\?config\=TeX-AMS-MML_HTMLorMML -f markdown -t html --css ~/.config/nvim/markdown-styles/markdown10.css % -o %:r.html <CR>
autocmd FileType markdown nnoremap <LocalLeader>t :TOC <CR>
autocmd FileType markdown nnoremap <silent> <Leader>v :! qutebrowser %:r.html&<CR>


" ------------------------------------------------------------------------
" Colors
" ------------------------------------------------------------------------
execute "set t_8f=\e[38;2;%lu;%lu;%lum"
execute "set t_8b=\e[48;2;%lu;%lu;%lum"

" Load custom variant of material theme
" source $HOME/.config/nvim/colors/material.vim

set termguicolors

let g:catppuccin_flavour = "frappe" " latte, frappe, macchiato, mocha

let g:material_theme_style='default'
let g:airline_theme='material'
let g:material_terminal_italics = 1
set background=dark

lua require("catppuccin").setup()

colorscheme catppuccin


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

 let g:CommandTPreferredImplementation='lua'


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
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
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
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

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

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add `:Header` command to switch between header and source
command! -nargs=0 Header :call 	CocAction('runCommand', 'clangd.switchSourceHeader')

" Add `:Hints` command
command! -nargs=0 Hints :call 	CocAction('runCommand', 'clangd.inlayHints.toggle')

" Coc explorer shizz
let g:coc_explorer_global_presets = {
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   }
\}

nnoremap <leader>f :CocCommand explorer --preset floating<CR>
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

" ------------------------------------------------------------------------
" Lua configs after last because it breaks highlighting
" ------------------------------------------------------------------------
lua << EOF
require('lualine').setup {
	options = {
		theme = "catppuccin"
		-- ... the rest of your lualine config
	}
}
EOF
