-- Custom keymaps can go here

-- Paste in visual mode without clobbering the unnamed register
vim.keymap.set("x", "p", [["_dP]])

-- Window navigation uses LazyVim's defaults; Herdr uses Ctrl+Option+hjkl.
