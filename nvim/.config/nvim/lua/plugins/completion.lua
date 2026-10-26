return {
  "saghen/blink.cmp",
  -- release tags ship a prebuilt fuzzy matcher binary
  version = "1.*",
  opts = {
    -- <Tab> accept / next snippet field, <S-Tab> prev field, <C-n>/<C-p> move,
    -- <C-space> open, <C-e> close, <C-k> signature
    keymap = { preset = "super-tab" },
    completion = {
      documentation = { auto_show = true },
    },
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
