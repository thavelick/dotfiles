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

-- map escape in normal mode to clear search highlights and close the quickfix window
vim.api.nvim_set_keymap('n', '<esc>', ':nohlsearch<cr>:ccl<cr>', { noremap = true, silent = true })

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


-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}
lspconfig.pyright.setup {}
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

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Harpoon configuration
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-h>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-t>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-e>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
