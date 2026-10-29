return {
  "vim-airline/vim-airline",
  init = function()
    vim.g.airline_symbols_ascii = 1
    -- filename relative to the git root (reponame:path/to/file)
    vim.g.airline_stl_path_style = "gitrepo"

    -- nvim 0.12 floats can show a statusline, and airline puts one on every
    -- window, so popups (completion docs, signature help) get a bogus one
    local function skip_float(win)
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        vim.w[win].airline_disable_statusline = 1
        -- local scope (:setlocal) so empty hides it rather than falling back
        vim.api.nvim_set_option_value("statusline", "", { scope = "local", win = win })
      end
    end
    vim.api.nvim_create_autocmd({ "WinNew", "WinEnter", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("airline_skip_floats", { clear = true }),
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do skip_float(win) end
      end,
    })

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
