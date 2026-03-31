return {
  before_init = function(_, config)
    local root = config.root_dir or vim.fn.getcwd()
    local venv = root .. "/venv"
    if vim.fn.isdirectory(venv) == 1 then
      config.settings.python.venvPath = root
      config.settings.python.venv = "venv"
      config.settings.python.pythonPath = venv .. "/bin/python"
    end
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
