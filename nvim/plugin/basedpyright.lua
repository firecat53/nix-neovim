require("lspconfig").basedpyright.setup {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard", -- change to 'recommended' for type checking
      }
    }
  }
}
