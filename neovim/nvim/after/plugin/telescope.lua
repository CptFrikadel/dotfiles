require("telescope").setup({
  defaults = {
    preview = {
      treesitter = false,
    },
  },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('n', '<leader>tr', builtin.resume, {})
vim.keymap.set('n', '<leader>ts', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>tt', builtin.builtin, {})
vim.keymap.set('n', '<leader>tq', builtin.quickfix, {})

vim.keymap.set('n', '<leader>gb', builtin.git_branches, {})
vim.keymap.set('n', '<leader>gl', builtin.git_commits, {})
