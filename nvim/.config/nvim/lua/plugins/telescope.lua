return {
	"nvim-telescope/telescope.nvim",
	opts = function(_, opts)
		opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
			hidden = true,
			file_ignore_patterns = { "^.git/" },
		})
	end,
}
