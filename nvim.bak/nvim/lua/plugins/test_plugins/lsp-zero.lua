return {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'}

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)
require('lspconfig').pyright.setup{}
require('lspconfig').lua_ls.setup{}
require('lspconfig').markdown.setup{}
