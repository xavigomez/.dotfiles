return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 300,
    },
    current_line_blame_formatter = "<author>, <author_time:%R>",
  },
  keys = {
    {
      "<leader>uB",
      function()
        require("gitsigns").toggle_current_line_blame()
      end,
      desc = "Toggle Inline Blame",
    },
  },
}
