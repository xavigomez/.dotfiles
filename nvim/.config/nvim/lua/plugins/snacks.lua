-- Terminal <C-hjkl> go through the herdr navigator so inline terminals at
-- nvim's edge escape to herdr panes. Floating terminals keep stock behavior:
-- the key is typed into the shell running inside the float.
local function term_nav(dir)
  return function()
    local nav = require("config.herdr-navigator")
    if nav.is_float() then
      local keys = vim.api.nvim_replace_termcodes("<C-" .. dir .. ">", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    else
      nav.move(dir)
    end
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", mode = "t", expr = false },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", mode = "t", expr = false },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", mode = "t", expr = false },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", mode = "t", expr = false },
        },
      },
    },
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
