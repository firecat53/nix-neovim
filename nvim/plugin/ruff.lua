require('lspconfig').ruff.setup({
  settings = {
    ruff = {
      -- Add any Ruff-specific settings here, for example:
      lint = {
        args = {"--select", "E,F,W,I"},
      }
    }
  },
  -- Disable hover in favor of basedpyright
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end
})
