return {
  "neovim/nvim-lspconfig",
  config = function()
    -- no diagnostic signs, so the sign column never pushes text right
    vim.diagnostic.config({ signs = false })

    -- completing a function gives `foo(|)` instead of filling in every
    -- parameter; <C-k> shows the signature for what goes where
    vim.lsp.config("zls", {
      settings = { zls = { enable_argument_placeholders = false } },
    })
    vim.lsp.enable("zls")
  end,
}
