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
        -- Closed (end-of-line) diagnostics dimmed toward the bg so they read
        -- as context; the expanded virtual lines (DiagnosticVirtualLines*)
        -- keep the full colors. See diagnostics in lsp.lua.
        local dim = function(c)
          return { fg = require("tokyoppuccin.util").blend_bg(colors, c, 0.6) }
        end
        hl.DiagnosticVirtualTextError = dim(colors.red)
        hl.DiagnosticVirtualTextWarn = dim(colors.yellow)
        hl.DiagnosticVirtualTextInfo = dim(colors.diag_info)
        hl.DiagnosticVirtualTextHint = dim(colors.hint)
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyoppuccin" },
  },
}
