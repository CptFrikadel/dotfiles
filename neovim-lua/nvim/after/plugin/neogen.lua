
local neogen = require("neogen")

neogen.setup({ snippet_engine = "luasnip" })

vim.keymap.set('n', "<leader>n", neogen.generate)
