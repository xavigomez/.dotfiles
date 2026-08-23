return {
  -- Tell LazyVim which colorscheme to apply; it handles loading the plugin.
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },

  -- LazyVim already sets the integrations and LSP underline styles.
  -- catppuccin also auto-detects installed plugins (auto_integrations).
  { "catppuccin/nvim", opts = { flavour = "mocha" } },
}
