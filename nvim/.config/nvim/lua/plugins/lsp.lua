-- Language support lives in lazyvim.json extras (:LazyExtras).
-- Only put things here that no extra covers.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- LazyVim has no CSS extra, so cssls is configured by hand.
        cssls = {},
      },
    },
  },

  -- Parsers not in LazyVim's defaults or in any enabled extra.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "scss", "jsonc" } },
  },
}
