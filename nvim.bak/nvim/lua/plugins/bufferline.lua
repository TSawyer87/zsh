return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		require("bufferline").setup({
			options = {
				buffer_picker = function()
					require("telescope.buffers").buffers()
					require("telescope.builtin.__lsp").buffers()
				end,
				-- Other Bufferline configurations
			},
		})
	end,
}
