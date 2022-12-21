vim.cmd [[
autocmd FileType markdown nnoremap <Leader>p :Pandoc pdf <CR>
autocmd FileType markdown nnoremap <Leader>b :Pandoc beamer <CR>
autocmd FileType markdown nnoremap <Leader>h :! pandoc --toc --standalone --mathjax=http://cdn.mathjax.org/mathjax/latest/MathJax.js\?config\=TeX-AMS-MML_HTMLorMML -f markdown -t html --css ~/.config/nvim/markdown-styles/markdown10.css % -o %:r.html <CR>
autocmd FileType markdown nnoremap <LocalLeader>t :TOC <CR>
autocmd FileType markdown nnoremap <silent> <Leader>v :! qutebrowser %:r.html&<CR>
]]
