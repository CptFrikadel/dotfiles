local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'clangd',
})

require'lspconfig'.lua_ls.setup {
    -- ... other configs
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim', 'tex' }
            }
        }
    }
}

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Insert}
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	--['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	--['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-space>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert,  select = true }),

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
	    { name = "nvim_lua" },
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

lsp.set_preferences({
	sign_icons = { }
})

lsp.on_attach(function(client, buffnr)
    local opts = {buffer = buffnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<leader>hh", vim.cmd.ClangdSwitchSourceHeader)
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

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


