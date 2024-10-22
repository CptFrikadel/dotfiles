local trouble = require("trouble")


trouble.setup()

vim.keymap.set('n', '<leader>d', trouble.toggle, {})

vim.keymap.set('n', '<leader>dn', function ()
	trouble.next({skip_groups = true, jump = true})
end, {})

vim.keymap.set('n', '<leader>dp', function ()
	trouble.previous({skip_groups = true, jump = true})
end, {})
