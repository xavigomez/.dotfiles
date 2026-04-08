return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			sources = {
				explorer = {
					hidden = true, -- <leader>e
					ignored = true,
				},
				files = {
					hidden = true, -- <leader><leader>
					ignored = true,
				},
			},
		},
	},
}
