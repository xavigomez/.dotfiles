return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      -- Don't let snacks generate a lazygit config. Stock lazygit inherits
      -- terminal_color_0..15 from the colorscheme, which is what it looks
      -- like when launched straight from the terminal: no rewritten colours,
      -- no nerd font icons.
      configure = false,

      -- Snacks defaults the float to no border; lazygit.nvim used rounded.
      win = { border = "rounded" },
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
