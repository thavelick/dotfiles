-- Enable spell checking
vim.o.spell = true
vim.o.spelllang = 'en_us'

-- Create color column at column 81
vim.opt.colorcolumn = '100'
vim.cmd[[highlight ColorColumn guibg=grey]]

require('packer').startup(function(use)
  use 'ctrlpvim/ctrlp.vim'
  use 'dense-analysis/ale'
  use 'github/copilot.vim'
  use {'junegunn/fzf', run = './install --all'}
  use 'junegunn/fzf.vim'
  use 'folke/tokyonight.nvim'
  use 'folke/which-key.nvim'
end)

-- Key timeout
vim.o.timeoutlen = 250

-- Configure which-key
require('which-key').setup({})

-- Set colorscheme
vim.cmd('colorscheme tokyonight')

-- Adjust Normal and ColorColumn highlights
vim.cmd([[highlight Normal ctermbg=NONE guibg=NONE]])
vim.cmd([[highlight ColorColumn ctermbg=grey]])

-- Clipboard configuration
vim.o.clipboard = 'unnamedplus'

-- CTRL-P settings
vim.g.ctrlp_map = '<c-p>'
vim.g.ctrlp_cmd = 'CtrlP'

-- ALE linters and fixers configuration
vim.g.ale_linters = { python = {'pylint'} }
vim.g.ale_fixers = { python = {'black'} }
vim.g.ale_fix_on_save = 1

-- Function to trim trailing whitespace
function _G.trim_whitespace()
  local l = vim.fn.line(".")
  local c = vim.fn.col(".")
  vim.cmd([[ %s/\s\+$//e ]])
  vim.fn.cursor(l, c)
end

-- Autocommand to trim whitespace before saving
vim.cmd([[autocmd BufWritePre * lua _G.trim_whitespace()]])

-- enable yaml for copilot
vim.g.copilot_filetypes = {
    yaml = 1,
}
