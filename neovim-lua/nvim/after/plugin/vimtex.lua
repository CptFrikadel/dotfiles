if (vim.fn.has('win32')) then
	vim.g.vimtex_view_general_viewer = 'SumatraPDF'
	vim.g.vimtex_view_general_options  = '-reuse-instance -forward-search @tex @line @pdf'
else
	vim.g.vimtex_view_method = "zathura"
end
