local function project_root()
  local dir = vim.fn.expand("%:p:h")
  local root = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]
  return vim.v.shell_error ~= 0 and dir or root
end

return {
  "junegunn/fzf.vim",
  dependencies = {
    { "junegunn/fzf", build = "./install --bin" },
  },
  config = function()
    vim.api.nvim_create_user_command("ProjectFiles", function(opts)
      vim.fn["fzf#vim#files"](project_root(), vim.fn["fzf#vim#with_preview"](), opts.bang and 1 or 0)
    end, { bang = true })

    vim.api.nvim_create_user_command("ProjectAg", function(opts)
      vim.fn["fzf#vim#ag"](opts.args, vim.fn["fzf#vim#with_preview"]({ dir = project_root() }), opts.bang and 1 or 0)
    end, { bang = true, nargs = "*" })

    vim.keymap.set("n", "<C-a>", "<cmd>ProjectAg<CR>")
    vim.keymap.set("n", "<C-p>", "<cmd>ProjectFiles<CR>")
  end,
}
