
require('nvim-treesitter').install({ "c", "cpp", "python", "lua", "rust" })

-- Auto-install missing parsers when entering a buffer
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if not lang then return end
    if pcall(vim.treesitter.language.inspect, lang) then
      vim.treesitter.start()
    else
      pcall(require('nvim-treesitter').install, { lang })
    end
  end,
})

require'treesitter-context'.setup{}

-- Textobjects
require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

local ts_select = require('nvim-treesitter-textobjects.select')
local ts_move = require('nvim-treesitter-textobjects.move')

-- Select textobjects
local select_keymaps = {
  ['aa'] = '@parameter.outer',
  ['ia'] = '@parameter.inner',
  ['af'] = '@function.outer',
  ['if'] = '@function.inner',
  ['ac'] = '@class.outer',
  ['ic'] = '@class.inner',
  ['ii'] = '@conditional.inner',
  ['ai'] = '@conditional.outer',
  ['il'] = '@loop.inner',
  ['al'] = '@loop.outer',
  ['at'] = '@comment.outer',
  ['it'] = '@comment.inner',
}

for key, query in pairs(select_keymaps) do
  vim.keymap.set({ 'x', 'o' }, key, function() ts_select.select_textobject(query) end)
end

-- Move to textobjects (repeatable via ; and , out of the box)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() ts_move.goto_next_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']a', function() ts_move.goto_next_start('@parameter.inner') end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function() ts_move.goto_next_end('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() ts_move.goto_previous_start('@function.outer') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[a', function() ts_move.goto_previous_start('@parameter.inner') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() ts_move.goto_previous_end('@function.outer') end)

-- Repeat last move using ; and ,
local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Make builtins also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
