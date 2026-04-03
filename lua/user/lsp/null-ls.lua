local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then return end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local function get_venv_cmd(bin)
  return function()
    local path = vim.fn.expand("%:p:h")
    while path ~= "/" do
      local cmd = path .. "/venv/bin/" .. bin
      if vim.fn.filereadable(cmd) == 1 then
        return cmd
      end
      path = vim.fn.fnamemodify(path, ":h")
    end
    return bin
  end
end


null_ls.setup({
  sources = {
    formatting.isort.with({ command = get_venv_cmd("isort") }),
    formatting.black.with({ command = get_venv_cmd("black") }),
    formatting.astyle,
    diagnostics.flake8.with({ command = get_venv_cmd("flake8") }),
  },
})

-- Format on save
vim.api.nvim_command([[autocmd BufWritePre *.py lua vim.lsp.buf.format({ async = false })]])
vim.api.nvim_command([[autocmd BufWritePre *.go lua vim.lsp.buf.format({ async = true })]])

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp" },
  callback = function()
    local filename = vim.fn.expand("%")
    vim.cmd("silent! write")
    vim.cmd("!astyle -n " .. filename .. " > /dev/null 2>&1")
    vim.cmd("silent! edit")
  end,
})
