local ls = require("luasnip")
local types = require("luasnip.util.types")


ls.config.set_config {
	-- Be able to jump back to last snippet
	history = true,

	updateevents = "TextChanged,TextChangedI",

	-- Autosnippets.. to try out
	enable_autosnippets = true
}


--[[
--		Keymap
--]]
--
-- C-k as jump/expand option
vim.keymap.set({ "i", "s"}, "<C-K>", function ()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, {silent = true })

-- C-j as jump/expand backwards option
vim.keymap.set({ "i", "s"}, "<C-J>", function ()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, {silent = true })


-- C-l cycle through list of options
vim.keymap.set( "i", "<C-L>", function ()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>")


--[[
--    Them snippets yo
--]]
local s = ls.s
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require('luasnip.extras.fmt').fmta
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

ls.add_snippets("all", {
		s("time", f(function() return os.date("%H:%M") end)),
		s("date", f(function() return os.date("%Y-%m-%d") end)),
})

ls.add_snippets("lua", {
	s("req",
		fmt([[local {} = require("{}")]], {
			f(function (import_name)
				local parts = vim.split(import_name[1][1], ".", true)
				return parts[#parts] or ""
			end, { 1 }),
			i(1),
		})
	),
})

ls.add_snippets("cpp", {
	s("ctst",
	fmta([[void CTest::<name>(uint32_t location)
{
  auto loc = GetContext().GetLocationContext(location);
  auto dut = GetContext().GetDut(location);

  <finish>
}]], {
		name = i(1),
		finish = i(0),
     })
    ),
	s("tst",
	fmta([[void <name>(uint32_t location);]], {name = i(1)})
	),

	s("atst",
	fmta([[root.AddTestStep("<name>", <duration>).Set(&CTest::<func>);]],
		{
			name = i(1),
			duration = i(2),
			func = i(3),
		})
	),

	s("ifabort",
	fmta([[if (!<expression>)
{
  X_INTERNAL("<what>");
}]],
	{
		expression = i(1),
		what = i(2),
	})
	),
	s("iffail",
	fmta([[if (!<expression>)
{
  Report::Failure("<what>");
  return false;
}]],
	{
		expression = i(1),
		what = i(2),
	})
	),
})

ls.add_snippets("tex", {
	s("new",
		fmta([[\NEW{<text>}<finish>]], {
			text = i(1),
			finish = i(0),
		})
	),

	s("item",
		fmta([[
\begin(itemize)
	\item <item>
\end(itemize)
]],
		{
			item = i(1),
		})
	),

	s("enum",
		fmta([[
\begin(enumerate)
	\item <item>
\end(enumerate)
]],
		{
			item = i(1),
		})
	),

	s("env",
		fmta([[
\begin(<env>)
	<finish>
\end(<also_env>)
]],
		{
			env = i(1),
			also_env = rep(1),
			finish = i(0),
		})
	),
})
