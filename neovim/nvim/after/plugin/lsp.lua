local lsp = require("lsp-zero")

vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities()
})

require("mason").setup({
    registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
    },
})

require('mason-lspconfig').setup({
  ensure_installed = {'lua_ls', 'clangd', 'pyright', 'rust_analyzer'},
  automatic_enable = false,
})

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Insert}
local cmp_mappings = cmp.mapping.preset.insert({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-Space>'] = cmp.mapping.confirm({ select = false }),
	['<CR>'] = cmp.mapping.confirm({ select = false }),

        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

	['<Tab>'] = function(fallback)
	  if not cmp.select_next_item() then
		if vim.bo.buftype ~= 'prompt' and has_words_before() then
		    cmp.complete()
		else
		    fallback()
		end
	    end
	end,
})


-- Call cmp.setup directly instead of using lsp's wrapper
cmp.setup({
	mapping = cmp_mappings,
	sources = cmp.config.sources({
	    { name = "copilot" },
	    { name = "nvim_lua" },
	    { name = "ctags" ,
		option = {
		    executable = "ctags",
		    trigger_characters_ft = { c = {".", "->"}, },
		}
	    },
	    { name = "nvim_lsp" },
	    { name = "path" },
	    { name = "luasnip" },
	    { name = "buffer", keyword_length = 5 },
	}),
	snippet = {
	    expand = function(args)
		require("luasnip").lsp_expand(args.body)
	    end,
	},
})

--lsp.on_attach(function(client, buffnr)
-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    local opts = {buffer = buffnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<leader>hh", vim.cmd.ClangdSwitchSourceHeader)
    vim.keymap.set("n", "gr", function() require('telescope.builtin').lsp_references() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

end,
})

lsp.setup()


vim.diagnostic.config({ 
     signs = true,
     underline = true,
     update_in_insert = false,
     virtual_text = true,
     -- virtual_text = { 
     --     prefix = '●', -- Could be '●', '▎', 'x', '■' 
     -- } 
 })


vim.lsp.config('lua_ls', {
    settings = {
	Lua = {
	    diagnostics = {
		globals = { 'vim' }
	    },
	    workspace = {
		-- make language server aware of runtime files
		library = {
		    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
		    [vim.fn.stdpath("config") .. "/lua"] = true,
		},
	    },
	}
    }
})
vim.lsp.enable('lua_ls')

vim.lsp.enable('pyright')

vim.lsp.config('clangd', {
    cmd = { "clangd",
	    "--query-driver=/opt/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-*",
	}
})
vim.lsp.enable('clangd')

vim.api.nvim_create_user_command('ClangdSwitchSourceHeader', function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = 'clangd' })
    if #clients == 0 then return vim.notify('clangd not attached', vim.log.levels.WARN) end
    local params = { uri = vim.uri_from_bufnr(0) }
    clients[1]:request('textDocument/switchSourceHeader', params, function(err, result)
        if err then return vim.notify(err.message, vim.log.levels.ERROR) end
        if result then vim.cmd.edit(vim.uri_to_fname(result)) end
    end)
end, { desc = 'Switch between source and header' })

vim.lsp.enable('rust_analyzer')

vim.lsp.enable('roslyn')

--require('sonarlint').setup({
--   server = {
--      cmd = {
--         --'sonarlint-language-server',
--         vim.fn.expand("$MASON/bin/sonarlint-language-server.cmd"),
--         -- Ensure that sonarlint-language-server uses stdio channel
--         '-stdio',
--         '-analyzers',
--         -- paths to the analyzers you need, using those for python and java in this example
--         vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
--         vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
--      }
--   },
--   filetypes = {
--      -- Tested and working
--      'python',
--      'cpp',
--   }
--})


require('copilot').setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require('copilot_cmp').setup()

