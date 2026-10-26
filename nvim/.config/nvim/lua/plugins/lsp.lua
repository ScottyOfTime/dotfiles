return {
  "neovim/nvim-lspconfig",
  config = function()
    -- no diagnostic signs, so the sign column never pushes text right
    vim.diagnostic.config({ signs = false })

    vim.lsp.enable("zls")
  end,
}
