return {
  "vim-airline/vim-airline",
  init = function()
    vim.g.airline_symbols_ascii = 1
    -- filename relative to the git root (reponame:path/to/file)
    vim.g.airline_stl_path_style = "gitrepo"

    -- with autochdir airline shows the full path, so use the 'file' part instead
    vim.api.nvim_create_autocmd("User", {
      pattern = "AirlineAfterInit",
      callback = function()
        vim.g.airline_section_c = vim.fn["airline#section#create"]({
          "%<", "file", vim.g.airline_symbols.space, "readonly", "coc_status", "lsp_progress",
        })
      end,
    })
  end,
}
