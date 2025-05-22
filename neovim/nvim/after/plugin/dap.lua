
vim.keymap.set('n', "<leader>db", function() require("dap").toggle_breakpoint() end)
vim.keymap.set('n', "<leader>du", function() require("dapui").toggle() end)
vim.keymap.set('n', "<leader>dc", function() require("dap").continue() end)
vim.keymap.set('n', "<leader>dC", function() require("dap").run_to_cursor() end)
vim.keymap.set('n', "<leader>dT", function() require("dap").terminate() end)



require("dapui").setup()
require("nvim-dap-virtual-text").setup()

require("dap-python").setup("~/AppData/Local/nvim-data/mason/packages/debugpy/venv/Scripts/python.exe")


local dap = require("dap")
dap.adapters.codelldb = {
  type = "executable",
  --command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"
  command = "C:/Users/Alexander/AppData/Local/nvim-data/mason/packages/codelldb/extension/adapter/codelldb.exe"

  -- On windows you may have to uncomment this:
  -- detached = false,
}


dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
	args = function()
		local args_string = vim.fn.input("Arguments: ")
		return vim.split(args_string, " ")
	end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
},
}
