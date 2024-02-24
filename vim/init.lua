-- Enable spell checking
vim.o.spell = true
vim.o.spelllang = 'en_us'

-- Create color column at column 100
vim.opt.colorcolumn = '100'
vim.cmd[[highlight ColorColumn guibg=grey]]

-- set the leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('packer').startup(function(use)
  use 'ctrlpvim/ctrlp.vim'
  use {'ThePrimeagen/harpoon', branch = 'harpoon2', requires = 'nvim-lua/plenary.nvim'}
  use 'dense-analysis/ale'
  use 'folke/which-key.nvim'
  use 'github/copilot.vim'
  use 'junegunn/fzf.vim'
  use 'neovim/nvim-lspconfig'
  use 'tpope/vim-sleuth'
  use 'wbthomason/packer.nvim'
  use {'folke/tokyonight.nvim', tag = 'v2.2.0'}
  use {'junegunn/fzf', run = './install --all'}
end)

-- Key timeout
vim.o.timeoutlen = 250

-- enable line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Configure which-key
local which_key = require('which-key')
which_key.setup({})

-- disable the arrow keys so I actually learn to use hjkl
for _, key in ipairs({'<up>', '<down>', '<left>', '<right>'}) do
  vim.keymap.set({'n', 'v', 'i'}, key, '<nop>', {noremap = true, silent = true})
end

-- map escape in normal mode to clear search highlights and close the quickfix window
vim.keymap.set('n', '<esc>', ':nohlsearch<cr>:ccl<cr>')

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

-- Setup language servers manually

-- Setup language servers with lspconfig
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}
lspconfig.pyright.setup {
  on_attach = function()
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0, desc = "Show hover documentation"})
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "Go to definition"})
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = 0, desc = "Show references"})

    which_key.register("<leader>d", { name = "Diagnostics" })
    vim.keymap.set("n", "<leader>df", vim.diagnostic.goto_next, { buffer = 0, desc = "Go to next diagnostic"})
    vim.keymap.set("n", "<leader>db", vim.diagnostic.goto_prev, { buffer = 0, desc = "Go to previous diagnostic"})
    vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { buffer = 0, desc = "Show diagnostics in loclist"})

    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = 0, desc = "Rename symbol"})
  end,
}
lspconfig.tsserver.setup {}
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'require', 'use'},
      },
    },
  },
}

-- Harpoon configuration
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "Add current file to Harpoon list" })
vim.keymap.set("n", "<C-h>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-t>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-e>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
