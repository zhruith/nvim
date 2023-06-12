if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= 
        \ line("$") | exe "normal! g'\"" | endif
endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'shatur/neovim-ayu'
Plug 'lewis6991/gitsigns.nvim'
"Plug 'puremourning/vimspector'
call plug#end()

inoremap <silent><expr><TAB> coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm(): 
      \"\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>


let g:markdown_fenced_languages = ['vim','help']

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    call CocActionAsync('doHover')
    " execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction


" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
"autocmd BufWritePre * silent call CocActionAsync('format')


" Symbol renaming.
nmap <leader>r <Plug>(coc-rename)

xmap <leader>f <Plug>(coc-format-selected)<cr>
nmap <leader>f <Plug>(coc-format-selected)<cr>
map <silent> <S-M-f> :CocCommand editor.action.formatDocument<cr>

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

nmap <leader>ac  <Plug>(coc-codeaction-cursor)
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

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
  nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  vnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
endif


" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

command! -nargs=0 Format :call   CocActionAsync('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Mappings for CoCList
nnoremap <silent><nowait> <space>d :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>x :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s :<C-u>CocList symbols<cr>
nnoremap <silent><nowait> <space>m :<C-u>CocList marketplace<cr>
nnoremap <silent><nowait> <space>b :<C-u>CocList buffers<cr>
nnoremap <silent><nowait> <space>j :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p :<C-u>CocListResume<CR>
nnoremap <silent><nowait> <space>e :<C-u>NvimTreeToggle<CR>
nnoremap <silent><nowait> <space>f :<C-u>CocList files<CR>
nnoremap <silent><nowait> <space>l :<C-u>CocList<CR>
nnoremap <silent><nowait> <space>g :<C-u>CocList grep<CR>
nnoremap <silent><nowait> <space>w :<C-u>CocList words<CR>
nnoremap <silent><nowait> <space>r :<C-u>CocList mru<CR>
nnoremap <silent><nowait> <space>v :<C-u>CocList vimcommands<CR>


"Goto keymap
map <silent> gj :<C-u>CocCommand document.jumpToNextSymbol<cr>
map <silent> gk :<C-u>CocCommand document.jumpToPrevSymbol<cr>

map <silent> gn :<C-u>bn<cr>
map <silent> gp :<C-u>bp<cr>
map <silent> gq :<C-u>b#\|bd#<cr>
map <silent> gW :<C-w>q<cr>
map <silent> gQ :<C-u>%bd!\|e#\|bd#<cr>
map <silent> ga :<C-u>e#<cr>

map <silent> gh 0
map <silent> gs ^
map <silent> gl $
map <silent> gc M
map <silent> ge G

vmap <silent> < <gv
vmap <silent> > >gv


nnoremap <silent><M-1> <Cmd>exe v:count . "ToggleTerm direction=horizontal"<CR>
nnoremap <silent><M-2> <Cmd>exe v:count . "ToggleTerm direction=vertical"<CR>
nnoremap <silent><M-3> <Cmd>exe v:count . "ToggleTerm direction=float"<CR>

autocmd TermEnter term://*toggleterm#* tnoremap <silent><M-1> <Cmd>exe v:count . "ToggleTerm"<CR>
autocmd TermEnter term://*toggleterm#* tnoremap <silent><M-2> <Cmd>exe v:count . "ToggleTerm"<CR>
autocmd TermEnter term://*toggleterm#* tnoremap <silent><M-3> <Cmd>exe v:count . "ToggleTerm"<CR>

"nnoremap <silent><A-1> <Cmd>exe v:count . "ToggleTerm"<CR>
"inoremap <silent><A-1> <Esc><Cmd>exe v:count . "ToggleTerm"<CR>

"""""""""""" swich window """"""""""""""""

map <c-h> <c-w>h
map <c-l> <c-w>l
map <c-j> <c-w>j
map <c-k> <c-w>k

inoremap <c-h> <Esc><c-w>h
inoremap <c-l> <Esc><c-w>l
inoremap <c-j> <Esc><c-w>j
inoremap <c-k> <Esc><c-w>k

tnoremap <c-h> <c-\><c-n><c-w>h
tnoremap <c-l> <c-\><c-n><c-w>l
tnoremap <c-j> <c-\><c-n><c-w>j
tnoremap <c-k> <c-\><c-n><c-w>k
tnoremap <c--> <c-\><c-n>"0pa
tnoremap <c-q> <c-\><c-n>


""""""""""""""" resize window """"""""""""""""""
nmap <silent><c-m-h> :vertical resize -2<cr>
nmap <silent><c-m-l> :vertical resize +2<cr>
nmap <silent><c-m-j> :resize -2<cr>
nmap <silent><c-m-k> :resize +2<cr>

inoremap <silent><c-m-h> <c-\><c-n>:vertical resize -2<cr>a
inoremap <silent><c-m-l> <c-\><c-n>:vertical resize +2<cr>a
inoremap <silent><c-m-j> <c-\><c-n>:resize -2<cr>a
inoremap <silent><c-m-k> <c-\><c-n>:resize +2<cr>a

tnoremap <silent><c-m-h> <c-\><c-n>:vertical resize -2<cr>a
tnoremap <silent><c-m-l> <c-\><c-n>:vertical resize +2<cr>a
tnoremap <silent><c-m-j> <c-\><c-n>:resize -2<cr>a
tnoremap <silent><c-m-k> <c-\><c-n>:resize +2<cr>a


"""""""""""""move line """""""""""""""""""

imap <m-j> <Esc>:m .+1<CR>a
imap <m-k> <Esc>:m .-2<CR>a
nmap <m-j> :m .+1<CR>
nmap <m-k> :m .-2<CR>
vmap <m-j> :m '>+1<CR>gv-gv
vmap <m-k> :m '<-2<CR>gv-gv

nnoremap <F3> :set hlsearch! <CR>


"Edit config setting file by $MYVIMRC
nnoremap <silent><nowait> <S-A-c> :e $MYVIMRC<CR>
nnoremap <silent><nowait> <S-A-l> :call <SID>OpenLuaConf()<CR>
nnoremap <silent><nowait> <S-A-r> :<c-u>so$MYVIMRC\|colo ayu<cr>

function! s:OpenLuaConf()
  let home = coc#util#get_config_home()
  execute 'edit '.fnameescape(home.'/conf.lua')
endfunction


" Theme setup

set termguicolors


let g:airline_powerline_fonts = 1

set number
set notimeout
set ignorecase
set smartcase


set nobackup
set nowritebackup

set updatetime=100

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set foldmethod=manual
set foldexpr=''

"set smartindent
filetype indent plugin on
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set signcolumn=yes

set nohlsearch
set cursorline
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾

set wildmenu
set wildmode=list:longest,full
set wildignore=*.dll,*.exe,*.jpg,*.gif,*.png

if has('win32') || has('win64')
  set shell=pwsh.exe
  "let &shellcmdflag = '-c' "for bash shell
  let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
  let &shellpipe    = '| Out-File -Encoding UTF8 %s'
  let &shellredir   = '| Out-File -Encoding UTF8 %s'
endif
set shellxquote= shellxquote=


runtime conf.lua
