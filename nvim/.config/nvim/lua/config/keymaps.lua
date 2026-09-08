-- Custom keymaps can go here

-- Paste in visual mode without clobbering the unnamed register
vim.keymap.set("x", "p", [["_dP]])

-- Seamless ctrl+hjkl across nvim splits and herdr panes (edge forwards to herdr).
-- Loaded on VeryLazy, so these override LazyVim's window navigation defaults.
local nav = require("config.herdr-navigator")
for key, desc in pairs({ h = "Left", j = "Lower", k = "Upper", l = "Right" }) do
  vim.keymap.set({ "n", "t" }, "<C-" .. key .. ">", function()
    nav.move(key)
  end, { desc = "Go to " .. desc .. " Window" })
end
