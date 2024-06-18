-- Fname: /home/sergio/.config/nvim/lua/utils.lua
-- Last Change: Wed, 01 Jun 2022 08:19
-- https://github.com/ibhagwan/nvim-lua/blob/main/lua/utils.lua

local user_cmd = vim.api.nvim_create_user_command
local execute = vim.api.nvim_command
local vim = vim
local opt = vim.opt -- global
local g = vim.g -- global for let options
local wo = vim.wo -- window local
local bo = vim.bo -- buffer local
local fn = vim.fn -- access vim functions
local cmd = vim.cmd -- vim commands
local api = vim.api -- access vim api

function _G.reload(package)
	package.loaded[package] = nil
	return require(package)
end

local M = {}

-- Todo: test this function
M.is_loaded = function(plugin_name)
	return package.loaded["plugin_name"] ~= nil
	-- return require("lazy.core.config").plugins[plugin_name]._.loaded
end

--@ rturns true or false
M.is_recording = function()
	return vim.fn.reg_recording() ~= nil
end

-- @param name module
M.safeRequire = function(module)
	local success, loadedModule = pcall(require, module)
	if success then
		return loadedModule
	end
	print("Error loading " .. module)
end

-- toggle_autopairs() -- <leader>tp -- toggle autopairs
M.toggle_autopairs = function()
	local ok, autopairs = pcall(require, "nvim-autopairs")
	if ok then
		-- if autopairs.state.disabled then
		if MPairs.state.disabled then
			autopairs.enable()
			vim.notify("autopairs on")
		else
			autopairs.disable()
			vim.notify("autopairs off")
		end
	else
		vim.notifylrrr("autopairs not available")
	end
end

M.toggleInlayHints = function()
	vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
end

--that pressing `.` will repeat the action.
--Example: `vim.keymap.set('n', 'ct', dot_repeat(function() print(os.clock()) end), { expr = true })`
--Setting expr = true in the keymap is required for this function to make the keymap repeatable
--based on gist: https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
M.dot_repeat = function(
	callback --[[Function]]
)
	return function()
		_G.dot_repeat_callback = callback
		vim.go.operatorfunc = "v:lua.dot_repeat_callback"
		return "g@l"
	end
end

M.vim_opt_toggle = function(opt, on, off, name)
	local message = name
	if vim.opt[opt]:get() == off then
		vim.opt[opt] = on
		message = message .. " Enabled"
	else
		vim.opt[opt] = off
		message = message .. " Disabled"
	end
	vim.notify(message)
end

-- https://blog.devgenius.io/create-custom-keymaps-in-neovim-with-lua-d1167de0f2c2
-- https://oroques.dev/notes/neovim-init/
M.map = function(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	-- vim.api.nvim_set_keymap(mode, lhs, rhs, options)
	vim.keymap.set(mode, lhs, rhs, options)
end

M.toggle_quicklist = function()
	if fn.empty(fn.filter(fn.getwininfo(), "v:val.quickfix")) == 1 then
		vim.cmd("copen")
	else
		vim.cmd("cclose")
	end
end

M.toggle_spell = function()
	vim.wo.spell = not vim.wo.spell
end

M.ToggleConcealLevel = function()
	vim.o.conceallevel = (vim.o.conceallevel == 0) and 2 or 0
	vim.notify("ConcealLevel set to: " .. vim.o.conceallevel, vim.log.levels.INFO)
end

M.edit_snippets = function()
	local status_ok, luasnip = pcall(require, "luasnip")
	if status_ok then
		-- require("luasnip.loaders.from_lua").edit_snippet_files()
		require("luasnip.loaders").edit_snippet_files()
	end
end

M.toggle_background = function()
	local current_bg = vim.opt.background:get()
	vim.opt.background = (current_bg == "light") and "dark" or "light"
end

M.blockwise_clipboard = function()
	vim.cmd("call setreg('+', @+, 'b')")
	print("set + reg: blockwise!")
end

-- this helps us paste a line from the clipboard that
-- has a new line
M.linewise_clipboard = function()
	vim.cmd("call setreg('+', @+, 'l')")
	print("set + reg: linewise!")
end

-- M.toggle_boolean_value_on_line = function()
--   local values = {
--     ["true"] = "false",
--     ["false"] = "true",
--     ["on"] = "off",
--     ["off"] = "on",
--     ["yes"] = "no",
--     ["no"] = "yes",
--     ["1"] = "0",
--     ["0"] = "1",
--     ["enable"] = "disable",
--     ["disable"] = "enable",
--     ["enabled"] = "disabled",
--     ["disabled"] = "enabled",
--     ["before"] = "after",
--     ["after"] = "before",
--     ["first"] = "last",
--     ["last"] = "first",
--     ["up"] = "down",
--     ["down"] = "up",
--   }
--
--   local function toggle_bool_value(word)
--     local toggleWord = values[word:sub(1, -2)]
--     if toggleWord == nil then
--       -- Check if the word ends with a comma
--       local wordWithoutComma = word:match("^(.-),$")
--       if wordWithoutComma and values[wordWithoutComma] then
--         return values[wordWithoutComma] .. ","
--       end
--       return word
--     end
--     return toggleWord
--   end
--
--   local current_line = vim.api.nvim_get_current_line()
--   local indent = current_line:match("^%s*") -- Get the leading whitespace
--   local line_words = {}
--   local bool_count = 0
--
--   for word in current_line:gmatch("[%w_'\"]+(?:=|,)?[%w_'\"]+") do
--     if values[word:sub(1, -2)] ~= nil then
--       bool_count = bool_count + 1
--     end
--     table.insert(line_words, word)
--   end
--
--   local cursor_word = vim.fn.expand("<cword>")
--
--   if bool_count == 1 then
--     for i, word in ipairs(line_words) do
--       if values[word:sub(1, -2)] ~= nil or word:match("^.+,$") then
--         line_words[i] = toggle_bool_value(word)
--       end
--     end
--   else
--     for i, word in ipairs(line_words) do
--       if word == cursor_word or word:match("^.+,$") then
--         line_words[i] = toggle_bool_value(word)
--         break
--       end
--     end
--   end
--
--   local new_line = indent .. table.concat(line_words, " ")
--   vim.api.nvim_replace_current_line(new_line)
-- end

-- vim.keymap.set("n", "<Leader>tb", toggle_boolean, {buffer = true})

-- source: https://www.reddit.com/r/neovim/comments/109018y/comment/j3vdaux/
M.list_snips = function()
	local ft_list = require("luasnip").available()[vim.o.filetype]
	local ft_snips = {}
	for _, item in pairs(ft_list) do
		ft_snips[item.trigger] = item.name
	end
	print(vim.inspect(ft_snips))
end
-- vim.api.nvim_create_user_command("SnipList", M.list_snips, {})

-- that's a false mistake
-- source: https://github.com/sagarrakshe/toggle-bool/blob/master/plugin/toggle_bool.py

-- https://www.reddit.com/r/vim/comments/p7xcpo/comment/h9nw69j/
--M.MarkdownHeaders = function()
--   local filename = vim.fn.expand("%")
--   local lines = vim.fn.getbufline('%', 0, '$')
--   local lines = vim.fn.map(lines, {index, value -> {"lnum": index + 1, "text": value, "filename": filename}})
--   local vim.fn.filter(lines, {_, value -> value.text =~# '^#\+ .*$'})
--   vim.cmd("call setqflist(lines)")
--   vim.cmd("copen")
--end
-- nmap <M-h> :cp<CR>
-- nmap <M-l> :cn<CR>

-- References
-- https://bit.ly/3HqvgRT
M.CountWordFunction = function()
	local hlsearch_status = vim.v.hlsearch
	local old_query = vim.fn.getreg("/") -- save search register
	local current_word = vim.fn.expand("<cword>")
	vim.fn.setreg("/", current_word)
	local wordcount = vim.fn.searchcount({ maxcount = 1000, timeout = 500 }).total
	local current_word_number = vim.fn.searchcount({ maxcount = 1000, timeout = 500 }).current
	vim.fn.setreg("/", old_query) -- restore search register
	print("[" .. current_word_number .. "/" .. wordcount .. "]")
	-- Below we are using the nvim-notify plugin to show up the count of words
	vim.cmd([[highlight CurrenWord ctermbg=LightGray ctermfg=Red guibg=LightGray guifg=Black]])
	vim.cmd([[exec 'match CurrenWord /\V\<' . expand('<cword>') . '\>/']])
	-- require("notify")("word '" .. current_word .. "' found " .. wordcount .. " times")
end

local transparency = 0
M.toggle_transparency = function()
	if transparency == 0 then
		vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
		local transparency = 1
	else
		vim.cmd("hi Normal guibg=#111111 ctermbg=black")
		local transparency = 0
	end
end
-- -- map('n', '<c-s-t>', '<cmd>lua require("core.utils").toggle_transparency()<br>')

-- TODO: change colors forward and backward
M.toggle_colors = function()
	local current_color = vim.g.colors_name
	if current_color == "gruvbox" then
		-- gruvbox light is very cool
		vim.cmd("colorscheme ayu-mirage")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "ayu" then
		vim.cmd("colorscheme catppuccin")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "catppuccin-mocha" then
		vim.cmd("colorscheme material")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "material" then
		vim.cmd("colorscheme rose-pine")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "rose-pine" then
		vim.cmd("colorscheme nordfox")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "nordfox" then
		vim.cmd("colorscheme monokai")
		vim.cmd("colo")
		vim.cmd("redraw")
	elseif current_color == "monokai" then
		vim.cmd("colorscheme tokyonight")
		vim.cmd("colo")
		vim.cmd("redraw")
	else
		--vim.g.tokyonight_transparent = true
		vim.cmd("colorscheme gruvbox")
		vim.cmd("colo")
		vim.cmd("redraw")
	end
end

-- https://vi.stackexchange.com/questions/31206
-- https://vi.stackexchange.com/a/36950/7339
M.flash_cursorline = function()
	local cursorline_state = lua
	print(vim.opt.cursorline:get())
	vim.opt.cursorline = true
	cursor_pos = vim.fn.getpos(".")
	vim.cmd([[hi CursorLine guifg=#FFFFFF guibg=#FF9509]])
	vim.fn.timer_start(200, function()
		vim.cmd([[hi CursorLine guifg=NONE guibg=NONE]])
		vim.fn.setpos(".", cursor_pos)
		if cursorline_state == false then
			vim.opt.cursorline = false
		end
	end)
end

-- https://www.reddit.com/r/neovim/comments/rnevjt/comment/hps3aba/
M.ToggleQuickFix = function()
	if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
		vim.cmd([[cclose]])
	else
		vim.cmd([[copen]])
	end
end
vim.cmd([[command! -nargs=0 -bar ToggleQuickFix lua require('core.utils').ToggleQuickFix()]])
vim.cmd([[cnoreab TQ ToggleQuickFix]])
vim.cmd([[cnoreab tq ToggleQuickFix]])

-- dos2unix
M.dosToUnix = function()
	M.preserve("%s/\\%x0D$//e")
	vim.bo.fileformat = "unix"
	vim.bo.bomb = true
	vim.opt.encoding = "utf-8"
	vim.opt.fileencoding = "utf-8"
end
vim.cmd([[command! Dos2unix lua require('core.utils').dosToUnix()]])

-- vim.diagnostic.goto_prev,
-- vim.diagnostic.open_float
-- vim.diagnostic.setloclist
M.toggle_diagnostics = function()
	if vim.diagnostic.is_disabled() then
		vim.diagnostic.enable()
		vim.notify("Diagnostic enabled")
	else
		vim.diagnostic.disable()
		vim.notify("Diagnostic disabled")
	end
end

M.squeeze_blank_lines = function()
	-- references: https://vi.stackexchange.com/posts/26304/revisions
	if vim.bo.binary == false and vim.opt.filetype:get() ~= "diff" then
		local old_query = vim.fn.getreg("/") -- save search register
		M.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn") -- set current search count number
		local result = vim.fn.searchcount({ maxcount = 1000, timeout = 500 }).current
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		M.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge")
		M.preserve("sil! keepp keepj %s/^\\s\\+$/\\r/ge")
		M.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e")
		vim.notify("Removed duplicated blank ines")
		if result > 0 then
			vim.api.nvim_win_set_cursor(0, { (line - result), col })
		end
		vim.fn.setreg("/", old_query) -- restore search register
	end
end

M.is_executable = function()
	local file = vim.fn.expand("%:p")
	local type = vim.fn.getftype(file)
	if type == "file" then
		local perm = vim.fn.getfperm(file)
		if string.match(perm, "x", 3) then
			return true
		else
			return false
		end
	end
end

M.increment = function(par, inc)
	return par + (inc or 1)
end

-- M.is_file = function()
--   local file = vim.fn.expand('<cfile>')
--   if vim.fs.isfile(file) == true then
--     return true
--   else
--     return false
--   end
-- end

M.reload_module = function(...)
	return require("plenary.reload").reload_module(...)
end

M.rerequire_module = function(name)
	M.reload_module(name)
	return require(name)
end

M.preserve = function(arguments)
	local arguments = string.format("keepjumps keeppatterns execute %q", arguments)
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_command(arguments)
	local lastline = vim.fn.line("$")
	if line > lastline then
		line = lastline
	end
	vim.api.nvim_win_set_cursor(0, { line, col })
end

--> :lua changeheader()
-- This function is called with the BufWritePre event (autocmd)
-- and when I want to save a file I use ":update" which
-- only writes a buffer if it was modified
M.changeheader = function()
	-- We only can run this function if the file is modifiable
	if not vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "modifiable") then
		return
	end
	if vim.fn.line("$") >= 7 then
		os.setlocale("en_US.UTF-8") -- show Sun instead of dom (portuguese)
		time = os.date("%a, %d %b %Y %H:%M")
		M.preserve("sil! keepp keepj 1,7s/\\vlast (modified|change):\\zs.*/ " .. time .. "/ei")
	end
end

M.choose_colors = function()
	local actions = require("telescope.actions")
	local actions_state = require("telescope.actions.state")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local sorters = require("telescope.sorters")
	local dropdown = require("telescope.themes").get_dropdown()

	function enter(prompt_bufnr)
		local selected = actions_state.get_selected_entry()
		local cmd = "colorscheme " .. selected[1]
		vim.cmd(cmd)
		actions.close(prompt_bufnr)
	end

	function next_color(prompt_bufnr)
		actions.move_selection_next(prompt_bufnr)
		local selected = actions_state.get_selected_entry()
		local cmd = "colorscheme " .. selected[1]
		vim.cmd(cmd)
	end

	function prev_color(prompt_bufnr)
		actions.move_selection_previous(prompt_bufnr)
		local selected = actions_state.get_selected_entry()
		local cmd = "colorscheme " .. selected[1]
		vim.cmd(cmd)
	end

	-- local colors = vim.fn.getcompletion("", "color")

	local opts = {

		finder = finders.new_table({
			"gruvbox",
			"catppuccin",
			"material",
			"rose-pine",
			"nordfox",
			"nightfox",
			"monokai",
			"tokyonight",
		}),
		-- finder = finders.new_table(colors),
		sorter = sorters.get_generic_fuzzy_sorter({}),

		attach_mappings = function(prompt_bufnr, map)
			map("i", "<CR>", enter)
			map("i", "<C-j>", next_color)
			map("i", "<C-k>", prev_color)
			map("i", "<C-n>", next_color)
			map("i", "<C-p>", prev_color)
			return true
		end,
	}

	local colors = pickers.new(dropdown, opts)

	colors:find()
end

return M
