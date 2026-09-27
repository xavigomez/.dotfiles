return {
  "laytan/cloak.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- must be loaded before BufEnter fires for the file
  opts = {
    cloak_on_leave = true, -- re-cloak on BufWinLeave, not just on entry
    -- cloak_length = nil keeps the mask the same width as the real value
    patterns = {
      { file_pattern = { ".env*", "*.env", ".dev.vars" }, cloak_pattern = "=.+" },
    },
  },
  -- <leader>u is LazyVim's ui/toggle group, so these show up in the which-key list.
  keys = {
    { "<leader>uk", "<cmd>CloakToggle<cr>", desc = "Toggle Cloak" },
    { "<leader>uK", "<cmd>CloakPreviewLine<cr>", desc = "Cloak Preview Line" },
  },
}
