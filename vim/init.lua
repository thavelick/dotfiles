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

-- enable line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- set the leader key to space
vim.g.mapleader = ' '

-- disable the arrow keys so I actually learn to use hjkl
vim.api.nvim_set_keymap('n', '<up>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<down>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<left>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<right>', '<nop>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', '<up>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<down>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<left>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<right>', '<nop>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<up>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<down>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<left>', '<nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<right>', '<nop>', { noremap = true, silent = true })


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

-- highlight all search matches
vim.o.hlsearch = true
