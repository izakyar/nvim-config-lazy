-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end

-- lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true
vim.opt.number = true
require("lazy").setup({
    -- Essential plugins
    	{ "nvim-lua/plenary.nvim" },
    	{ "nvim-telescope/telescope.nvim" },
    	{ "kyazdani42/nvim-tree.lua" },
    	{ "tpope/vim-fugitive" },
    	{ "wsdjeg/vim-assembly" },
    	{ 'echasnovski/mini.nvim', version = false },
	

    -- Rust-specific plugins
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "mrcjkb/rustaceanvim" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'rafamadriz/friendly-snippets',
        },
    },
    { "jose-elias-alvarez/null-ls.nvim" },

    -- Enhancements
    { "folke/which-key.nvim" },
    { "folke/todo-comments.nvim" },
    { "sindrets/diffview.nvim" },
    { "nvim-lualine/lualine.nvim" },
    { "folke/tokyonight.nvim" }, -- Colorscheme
    { "mfussenegger/nvim-dap" },
    { "norcalli/nvim-colorizer.lua" }, -- Colorizer
}, {
    defaults = {
        lazy = true,
        config = true,
    },
})

-- nvim-colorizer setup
require("colorizer").setup()

-- Autocommand for setting Assembly syntax
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.asm", "*.s", "*.S"},
    callback = function()
        vim.opt_local.syntax = "nasm"
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
})

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "rust_analyzer" },
}

-- LSP configuration (rust-analyzer)
local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup {
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format { bufnr = bufnr }
            end,
        })
    end,
    settings = {
        ["rust-analyzer"] = {
            -- Example settings (uncomment to enable inlay hints)
            --inlayHints = {
            --    enable = true
            --},
        },
    },
}

-- Treesitter configuration
require("nvim-treesitter.configs").setup {
    ensure_installed = { "rust" },
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enable = true },
}

-- Completion (nvim-cmp) configuration
local cmp = require 'cmp'
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    }),
})

-- null-ls setup (for formatters and linters)
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.rustfmt,
        -- Add other formatters/linters as needed
    },
})

-- which-key setup
require("which-key").setup()

-- Colorscheme setup
vim.cmd [[colorscheme tokyonight]]

-- lualine setup
require('lualine').setup {
    options = {
        theme = 'tokyonight',
    }
}

-- todo-comments setup
require("todo-comments").setup()

-- nvim-tree setup
require("nvim-tree").setup {}

-- diffview setup
require("diffview").setup {}

require('lazy').setup({
  'atiladefreitas/lazyclip',
  config = function() 
    require('lazyclip').setup({ 
      -- Your custom configuration options here 
    }) 
  end,
  keys = { 
    { "<leader>cw", desc = "Open Clipboard Manager" }, 
  },
  -- Optional: Load plugin when yanking text
  event = { "TextYankPost" }, 
})
require('mini.indentscope').setup({symbol = "❯"})
require('mini.animate').setup()