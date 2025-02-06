return {
  cmd = {'gopls'},  -- Make sure gopls is installed and in your PATH
  filetypes = {'go', 'gomod'},
  root_dir = require('lspconfig').util.root_pattern('go.work', 'go.mod', '.git'),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}
