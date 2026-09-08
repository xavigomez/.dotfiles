-- Tokyoppuccin — the Zed theme's official nvim port, by the theme's creator
-- (replaced our hand-rolled catppuccin-override port once it appeared).
-- nvim is truecolor-sovereign, so terminal chrome (ghostty) is unaffected;
-- the only local deviation is the background, matched to the terminal
-- chrome (ghostty TokyoNight Moon #222436) instead of the theme's #24283b,
-- floats/explorer included, so the editor blends into the terminal.
return {
  {
    "EmmanuelVernet/tokyoppuccin.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      on_colors = function(colors)
        colors.bg = "#222436"
      end,
      on_highlights = function(hl, colors)
        hl.NormalFloat = { fg = colors.fg, bg = colors.bg }
        hl.FloatBorder = { fg = colors.blue, bg = colors.bg }
        hl.FloatTitle = { bg = colors.bg }
        hl.NeoTreeNormal = { fg = colors.fg, bg = colors.bg }
        hl.NeoTreeNormalNC = { fg = colors.fg, bg = colors.bg }
        hl.NeoTreeEndOfBuffer = { bg = colors.bg }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyoppuccin" },
  },
}
