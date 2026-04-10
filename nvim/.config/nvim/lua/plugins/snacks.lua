return {
	"folke/snacks.nvim",
	opts = {
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
