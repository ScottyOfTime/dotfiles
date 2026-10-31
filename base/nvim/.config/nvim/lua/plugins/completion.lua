return {
  "saghen/blink.cmp",
  -- release tags ship a prebuilt fuzzy matcher binary
  version = "1.*",
  init = function()
    vim.api.nvim_create_user_command("CompletionToggle", function()
      vim.g.completion_enabled = vim.g.completion_enabled == false
      local msg = "completion " .. (vim.g.completion_enabled and "on" or "off")
      if vim.g.completion_enabled and #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
        msg = msg .. " (no LSP in this buffer, so inactive here)"
      end
      print(msg)
    end, {})
  end,
  opts = {
    -- off when toggled off, and in buffers without an LSP (cmdline unaffected)
    enabled = function()
      if vim.g.completion_enabled == false then return false end
      if vim.api.nvim_get_mode().mode == "c" then return true end
      return vim.bo.buftype ~= "prompt" and #vim.lsp.get_clients({ bufnr = 0 }) > 0
    end,
    keymap = { preset = "super-tab" },
    completion = {
      documentation = { auto_show = true },
    },
    -- floats the signature with the current parameter highlighted; only on
    -- <C-k>, since auto-popping it covers the line above
    signature = {
      enabled = true,
      trigger = { enabled = false },
      window = { show_documentation = true },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
