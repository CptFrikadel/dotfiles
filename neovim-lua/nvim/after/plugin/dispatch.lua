
-- Set MSBuild as the make program whenever there is a sln file present
if vim.fn.filereadable("*.sln") then
	vim.opt.makeprg = 'MSBuild.exe'
	vim.opt.errorformat = {' %#%f(%l\\,%c): %m'}
end
