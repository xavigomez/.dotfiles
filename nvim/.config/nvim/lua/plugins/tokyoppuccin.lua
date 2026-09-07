-- Tokyoppuccin — port of the Zed theme (EmmanuelVernet/zed-tokyoppuccin).
-- Catppuccin surfaces with Tokyo Night text/syntax accents. The blend only
-- exists as a Zed theme, so this recreates it: catppuccin/nvim (frappé) as
-- the base, syntax colors lifted verbatim from the Zed theme JSON (Storm and
-- Frappé variants share identical syntax; only their backgrounds differ),
-- and the editor background matched to the terminal chrome instead.
-- nvim is truecolor-sovereign, so terminal chrome (ghostty) is unaffected.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "frappe",
      custom_highlights = function()
        return {
          -- editor text: Tokyo Night fg, bg matched to the terminal chrome
          -- (ghostty TokyoNight Moon #222436) instead of frappé base #303446.
          Normal = { fg = "#a9b1d6", bg = "#222436" },
          NormalNC = { fg = "#a9b1d6", bg = "#222436" },
          LineNr = { fg = "#474f75" },

          Comment = { fg = "#565f89", style = { "italic" } },
          ["@comment"] = { fg = "#565f89", style = { "italic" } },
          ["@comment.documentation"] = { fg = "#949cbb", style = { "italic" } },
          ["@comment.error"] = { fg = "#e78284", style = { "italic" } },
          ["@comment.warning"] = { fg = "#e5c890", style = { "italic" } },
          ["@comment.note"] = { fg = "#f2d5cf", style = { "italic" } },
          ["@comment.todo"] = { fg = "#eebebe", style = { "italic" } },

          Keyword = { fg = "#bb9af7" },
          ["@keyword"] = { fg = "#bb9af7" },
          ["@keyword.function"] = { fg = "#bb9af7" },
          ["@keyword.conditional"] = { fg = "#ff8bcb" },
          ["@keyword.conditional.ternary"] = { fg = "#ff8bcb" },
          ["@keyword.repeat"] = { fg = "#ff8bcb" },
          ["@keyword.return"] = { fg = "#ff8bcb" },
          ["@keyword.operator"] = { fg = "#ff8bcb" },
          ["@keyword.exception"] = { fg = "#ff8bcb" },
          ["@keyword.import"] = { fg = "#ff8bcb" },
          ["@keyword.coroutine"] = { fg = "#ff8bcb" },
          ["@keyword.modifier"] = { fg = "#ff8bcb" },
          ["@keyword.type"] = { fg = "#ff8bcb" },
          ["@keyword.debug"] = { fg = "#ff8bcb" },
          ["@keyword.directive"] = { fg = "#ff8bcb" },
          ["@keyword.directive.define"] = { fg = "#ff8bcb" },

          Function = { fg = "#7aa2f7" },
          ["@function"] = { fg = "#7aa2f7" },
          ["@function.call"] = { fg = "#7aa2f7" },
          ["@function.method"] = { fg = "#7aa2f7" },
          ["@function.method.call"] = { fg = "#7aa2f7" },
          ["@function.builtin"] = { fg = "#ef9f76" },
          ["@function.macro"] = { fg = "#81c8be" },
          ["@attribute"] = { fg = "#ef9f76" },

          String = { fg = "#a6d189" },
          ["@string"] = { fg = "#a6d189" },
          ["@string.documentation"] = { fg = "#81c8be" },
          ["@string.escape"] = { fg = "#f4b8e4" },
          ["@string.regexp"] = { fg = "#ef9f76" },
          ["@string.special"] = { fg = "#f4b8e4" },
          ["@string.special.path"] = { fg = "#f4b8e4" },
          ["@string.special.symbol"] = { fg = "#e8a9a9" },
          ["@string.special.url"] = { fg = "#f2d5cf", style = { "italic" } },
          Character = { fg = "#81c8be" },
          ["@character"] = { fg = "#81c8be" },
          ["@character.special"] = { fg = "#f4b8e4" },

          Type = { fg = "#e0af68" },
          ["@type"] = { fg = "#e0af68" },
          ["@type.builtin"] = { fg = "#ca9ee6", style = { "italic" } },
          ["@type.definition"] = { fg = "#e5c890" },

          Constant = { fg = "#ef9f76" },
          ["@constant"] = { fg = "#ef9f76" },
          ["@constant.builtin"] = { fg = "#ef9f76" },
          ["@constant.macro"] = { fg = "#ca9ee6" },
          Number = { fg = "#ef9f76" },
          ["@number"] = { fg = "#ef9f76" },
          ["@number.float"] = { fg = "#ef9f76" },
          Boolean = { fg = "#ef9f76" },
          ["@boolean"] = { fg = "#ef9f76" },

          -- the signature Zed look: teal italic variables (Tokyo Night #0db9d7)
          ["@variable"] = { fg = "#0db9d7", style = { "italic" } },
          ["@variable.builtin"] = { fg = "#e78284" },
          ["@variable.member"] = { fg = "#8caaee" },
          ["@variable.parameter"] = { fg = "#e0af68", style = { "italic" } },
          ["@property"] = { fg = "#7aa2f7" },

          Operator = { fg = "#99d1db" },
          ["@operator"] = { fg = "#99d1db" },
          ["@punctuation.bracket"] = { fg = "#7ac5e2" },
          ["@punctuation.delimiter"] = { fg = "#7ac5e2" },
          ["@punctuation.special"] = { fg = "#f4b8e4" },
          ["@constructor"] = { fg = "#eebebe" },
          ["@module"] = { fg = "#e5c890", style = { "italic" } },
          ["@label"] = { fg = "#85c1dc" },

          ["@tag"] = { fg = "#8caaee" },
          ["@tag.attribute"] = { fg = "#e5c890", style = { "italic" } },
          ["@tag.delimiter"] = { fg = "#81c8be" },

          ["@markup.heading"] = { fg = "#c6d0f5", style = { "bold" } },
          ["@markup.italic"] = { fg = "#ea999c", style = { "italic" } },
          ["@markup.strong"] = { fg = "#ea999c", style = { "bold" } },
          ["@markup.link.label"] = { fg = "#babbf1" },
          ["@markup.link.url"] = { fg = "#8caaee", style = { "italic" } },
          ["@markup.raw"] = { fg = "#a6d189" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-frappe" },
  },
}
