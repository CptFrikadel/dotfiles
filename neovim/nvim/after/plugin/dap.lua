
vim.keymap.set('n', "<leader>db", function() require("dap").toggle_breakpoint() end)
vim.keymap.set('n', "<leader>du", function() require("dapui").toggle() end)
vim.keymap.set('n', "<leader>dc", function() require("dap").continue() end)
vim.keymap.set('n', "<leader>dC", function() require("dap").run_to_cursor() end)
vim.keymap.set('n', "<leader>dT", function() require("dap").terminate() end)



require("dapui").setup({
  layouts = { {
        elements = { {
            id = "scopes",
            size = 0.35
          }, {
            id = "breakpoints",
            size = 0.2
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.1
          } },
        position = "left",
        size = 70
      }, {
        elements = { {
            id = "repl",
            size = 0.5
          }, {
            id = "console",
            size = 0.5
          } },
        position = "bottom",
        size = 20
      } },
})

require("nvim-dap-virtual-text").setup()

local function IsWindows()
    local sysname = vim.loop.os_uname().sysname

    if string.find(sysname, "Windows") then
      return true
    else
      return false
    end
end


if IsWindows() then
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
else
  local dap = require("dap")
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "gdb",
      request = "launch",
      program = function()
	return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = "${workspaceFolder}",
      stopAtBeginningOfMainSubprogram = false,
    },
    {
      name = "Select and attach to process",
      type = "gdb",
      request = "attach",
      program = function()
	 return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      pid = function()
	 local name = vim.fn.input('Executable name (filter): ')
	 return require("dap.utils").pick_process({ filter = name })
      end,
      cwd = '${workspaceFolder}'
    },
    {
      name = 'Attach to gdbserver :1234',
      type = 'gdb',
      request = 'attach',
      target = 'localhost:1234',
      program = function()
	 return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}'
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end
