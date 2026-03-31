local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then return end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

-- Walk up from cwd to find project root by marker files
local function find_project_root(markers)
  local path = vim.fn.getcwd()
  while path ~= "/" do
    for _, marker in ipairs(markers) do
      if vim.fn.filereadable(path .. "/" .. marker) == 1 then
        return path
      end
    end
    path = vim.fn.fnamemodify(path, ":h")
  end
  return vim.fn.getcwd()
end

-- Find venv/ (not .venv) at project root
local function find_venv(root)
  local venv = root .. "/venv"
  return vim.fn.isdirectory(venv) == 1 and venv or nil
end

local py_root = find_project_root({ ".flake8", "isort.cfg", ".isort.cfg", "pyproject.toml", "setup.cfg" })
local venv    = find_venv(py_root)

null_ls.setup({
  sources = {
    -- isort: reads isort.cfg from project root; venv tells it which pkgs are third-party
    formatting.isort.with({
      extra_args = (function()
        local args = { "--settings-path=" .. py_root .. "/.isort.cfg" }
        if venv then table.insert(args, "--virtual-env=" .. venv) end
        return args
      end)(),
    }),

    -- black: no config needed, reads pyproject.toml automatically
    formatting.black.with({ extra_args = { "--fast" } }),

    formatting.astyle,

    -- flake8: reads .flake8 from project root; venv set so it resolves third-party imports
    diagnostics.flake8.with({
      extra_args = { "--config=" .. py_root .. "/.flake8" },
      env = venv and { VIRTUAL_ENV = venv, PATH = venv .. "/bin:" .. vim.env.PATH } or nil,
    }),
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
