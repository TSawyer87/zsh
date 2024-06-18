return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		winopts =
			{
				split = "belowright 10new",
				border = "single",
				preview = {
					hidden = "hidden",
					border = "border",
					title = false,
					layout = "horizontal",
					horizontal = "right:50%",
				},
			},
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
	end,
}
