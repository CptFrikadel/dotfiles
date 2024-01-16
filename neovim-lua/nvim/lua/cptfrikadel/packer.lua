-- This file can be loaded by calling `lua require('plugins')` from your init.vim


local ensure_packer = function()

    local fn = vim.fn

    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

    if fn.empty(fn.glob(install_path)) > 0 then

        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})

        vim.cmd [[packadd packer.nvim]]

        return true

    end

    return false

end



local packer_bootstrap = ensure_packer()


-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]


return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.4',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Colors
  use({
	  'rose-pine/neovim',
	  as = 'rose-pine',
	  config = function()
		  vim.cmd('colorscheme rose-pine')
	  end
  })

  -- Treesitter
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

  -- Harpoon
  use('ThePrimeagen/harpoon')

  use('tpope/vim-fugitive')

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},
		  {'delphinus/cmp-ctags'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  --{'rafamadriz/friendly-snippets'},
	  }
  }

  use {
	  "nvim-treesitter/nvim-treesitter-textobjects",
	  after = "nvim-treesitter",
	  requires = "nvim-treesitter/nvim-treesitter",
  }

  use('nvim-lualine/lualine.nvim')

  use('lervag/vimtex')
  use('vim-pandoc/vim-pandoc')
  use('ap/vim-css-color')
  use('tpope/vim-surround')
  use('airblade/vim-gitgutter')
  use('tpope/vim-sleuth')
  use('Yggdroot/indentLine')
  use('tpope/vim-obsession')
  use('rhysd/vim-clang-format')
  use('stevearc/dressing.nvim')
  use('tpope/vim-dispatch')

  use({
	  "iamcco/markdown-preview.nvim",
	  run = function() vim.fn["mkdp#util#install"]() end,
  })


end)
