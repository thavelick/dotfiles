set spell
set spelllang=en_us
call matchadd('ColorColumn', '\%81v', 100)

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'folke/tokyonight.nvim'
Plug 'folke/which-key.nvim'
call plug#end()

set timeoutlen=250
lua require("which-key").setup()

colorscheme tokyonight
highlight Normal ctermbg=NONE guibg=NONE
highlight ColorColumn ctermbg=grey


set clipboard+=unnamedplus

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:ale_linters = {
\   'python': ['pylint'],
\}
let g:ale_fixers = {'python': ['black']}
let g:ale_fix_on_save = 1

fun! TrimWhitespace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call TrimWhitespace()
