set notimeout
set spell
set spelllang=en_us
highlight clear SpellBad
highlight SpellBad cterm=underline ctermfg=blue gui=underline guifg=yellow


highlight ColorColumn ctermbg=grey
call matchadd('ColorColumn', '\%81v', 100)

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:ale_linters = {
\   'python': ['pylint'],
\}
let g:ale_fixers = {'python': ['black']}
let g:ale_fix_on_save = 1


