return {
  "folke/snacks.nvim",
  opts = {
    -- Snacks derives lazygit's theme from highlight groups. Two of its
    -- defaults resolve badly under catppuccin: FloatBorder (#11111b) is
    -- darker than the background, making inactive panel titles invisible,
    -- and DiagnosticError resolves to pure #ff0000 rather than mocha red.
    lazygit = {
      theme = {
        inactiveBorderColor = { fg = "NonText" },
        unstagedChangesColor = { fg = "ErrorMsg" },
      },
    },
    picker = {
      sources = {
        explorer = {
          hidden = true, -- <leader>e
          ignored = true,
          exclude = { "node_modules", ".git" },
        },
        files = {
          hidden = true, -- <leader><leader>
          ignored = true,
          exclude = { "node_modules", ".git" },
        },
      },
    },
  },
}
