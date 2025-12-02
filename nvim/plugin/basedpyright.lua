vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard", -- change to 'recommended' for type checking
      }
    }
  }
})

vim.lsp.enable("basedpyright")
