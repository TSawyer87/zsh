return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/vaults/**.md",
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
		"BufReadPre home/jr/vaults/personal/py4e/**.md",
		"BufNewFile home/jr/vaults/personal/Python/**.md",
	},
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/vaults/personal",
			},
			{
				name = "Python",
				path = "~/vaults/personal/Python",
			},
			{
				name = "no-vault",
				path = function()
					-- alternatively use the CWD:
					-- return assert(vim.fn.getcwd())
					return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
				end,
				overrides = {
					notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
					new_notes_location = "current_dir",
					templates = {
						folder = vim.NIL,
					},
					disable_frontmatter = true,
				},
				{
					-- other fields ...

					templates = {
						folder = "/home/jr/vaults/personal/templates",
						date_format = "%Y-%m-%d-%a",
						time_format = "%H:%M",
					},
					-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
					-- URL it will be ignored but you can customize this behavior here.
					---@param url string
					follow_url_func = function(url)
						-- Open the URL in the default web browser.
						vim.fn.jobstart({ "open", url }) -- Mac OS
						-- vim.fn.jobstart({"xdg-open", url})  -- linux
					end,
					completion = {
						-- Set to false to disable completion.
						nvim_cmp = true,
						-- Trigger completion at 2 chars.
						min_chars = 2,
					},
					-- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
					-- way then set 'mappings = {}'.
					mappings = {
						-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
						["gf"] = {
							action = function()
								return require("obsidian").util.gf_passthrough()
							end,
							opts = { noremap = false, expr = true, buffer = true },
						},
						-- Toggle check-boxes.
						["<leader>ch"] = {
							action = function()
								return require("obsidian").util.toggle_checkbox()
							end,
							opts = { buffer = true },
						},
						-- Smart action depending on context, either follow link or toggle checkbox.
						["<cr>"] = {
							action = function()
								return require("obsidian").util.smart_action()
							end,
							opts = { buffer = true, expr = true },
						},
					},
					new_notes_location = "current_dir",
					picker = {
						-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
						name = "telescope.nvim",
						-- Optional, configure key mappings for the picker. These are the defaults.
						-- Not all pickers support all mappings.
						mappings = {
							-- Create a new note from your query.
							new = "<C-x>",
							-- Insert a link to the selected note.
							insert_link = "<C-l>",
						},
					},
					ui = {
						enable = true, -- set to false to disable all additional syntax features
						update_debounce = 200, -- update delay after a text change (in milliseconds)
						max_file_length = 5000, -- disable UI features for files with more than this many lines
						-- Define how various check-boxes are displayed
						checkboxes = {
							-- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
							[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
							["x"] = { char = "", hl_group = "ObsidianDone" },
							[">"] = { char = "", hl_group = "ObsidianRightArrow" },
							["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
							["!"] = { char = "", hl_group = "ObsidianImportant" },
							-- Replace the above with this if you don't have a patched font:
							-- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
							-- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

							-- You can also add more custom ones...
						},
						-- Use bullet marks for non-checkbox lists.
						bullets = { char = "•", hl_group = "ObsidianBullet" },
						external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
						-- Replace the above with this if you don't have a patched font:
						-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
						reference_text = { hl_group = "ObsidianRefText" },
						highlight_text = { hl_group = "ObsidianHighlightText" },
						tags = { hl_group = "ObsidianTag" },
						block_ids = { hl_group = "ObsidianBlockID" },
						hl_groups = {
							-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
							ObsidianTodo = { bold = true, fg = "#f78c6c" },
							ObsidianDone = { bold = true, fg = "#89ddff" },
							ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
							ObsidianTilde = { bold = true, fg = "#ff5370" },
							ObsidianImportant = { bold = true, fg = "#d73128" },
							ObsidianBullet = { bold = true, fg = "#89ddff" },
							ObsidianRefText = { underline = true, fg = "#c792ea" },
							ObsidianExtLinkIcon = { fg = "#c792ea" },
							ObsidianTag = { italic = true, fg = "#89ddff" },
							ObsidianBlockID = { italic = true, fg = "#89ddff" },
							ObsidianHighlightText = { bg = "#75662e" },
						},
					},
					{
						name = "no-vault",
						path = function()
							-- alternatively use the CWD:
							-- return assert(vim.fn.getcwd())
							return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
						end,
						overrides = {
							notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
							new_notes_location = "current_dir",
							templates = {
								folder = vim.NIL,
							},
							disable_frontmatter = true,
						},
					},
				},
			},
		},
	},
}
