local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.black.with({ extra_args = { "--fast" } }),
    formatting.astyle,
    diagnostics.flake8.with({ extra_args = { "--config=/Users/elliott/.flake8" } })
	},
})

vim.api.nvim_command [[autocmd BufWritePre *.py lua vim.lsp.buf.format({ async = true })]]

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.c,*.cpp",  -- Adjust patterns for your file types
    callback = function()
        vim.cmd("silent! !astyle %")  -- Change path to your Astyle options file
        vim.cmd("edit!")  -- Reload the file to see changes
    end,
})

