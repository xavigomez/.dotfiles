-- Automatically enable obsidian.nvim features when entering markdown files in vault
-- and disable them when leaving to keep completion clean elsewhere

local vault_root = vim.fn.expand("~/.obsidian")
local obsidian_enabled = false

local function in_vault()
	return vim.fn.expand("%:p"):find(vault_root, 1, true) == 1
end

local function enable_obsidian_features()
	if not obsidian_enabled then
		obsidian_enabled = true
		require("lazy.core.loader").load("obsidian.nvim", { event = "BufEnter" })
		vim.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
	end
end

local function disable_obsidian_features()
	if obsidian_enabled then
		pcall(vim.api.nvim_buf_del_keymap, 0, "n", "gf")
		pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>ch")
		pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<cr>")
		obsidian_enabled = false
	end
end

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.md",
	callback = function()
		if in_vault() then
			enable_obsidian_features()
		end
	end,
})

vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "*.md",
	callback = function()
		if in_vault() then
			disable_obsidian_features()
		end
	end,
})

-- VimEnter: load when nvim is opened inside the vault (with or without a file)
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if vim.fn.getcwd():find(vault_root, 1, true) == 1 or in_vault() then
			enable_obsidian_features()
		end
	end,
})

vim.api.nvim_create_user_command("ObsidianEnableManual", enable_obsidian_features, {
	desc = "Manually enable Obsidian.nvim features",
})

vim.api.nvim_create_user_command("ObsidianDisableManual", disable_obsidian_features, {
	desc = "Manually disable Obsidian.nvim features",
})
