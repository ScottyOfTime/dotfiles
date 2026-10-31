return {
  "Luxed/ayu-vim",
  lazy = false,
  priority = 1000,
  config = function()
    local mode = vim.trim(vim.fn.system("darkman get"))
    vim.g.ayucolor = mode == "light" and "light" or "dark"
    vim.cmd.colorscheme("ayu")
  end,
}
