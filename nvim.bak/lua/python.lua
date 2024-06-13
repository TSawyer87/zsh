function OpenTerminalBuffer(termType)
	-- open a terminal buffer
	vim.api.nvim_exec2("belowright split | term", { output = true })
	-- save terminal buffer
	local term_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_chan_send(vim.api.nvim_get_option_value("channel", { buf = term_buf }), termType .. "\r")
end

local function nextLine()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local total_lines = vim.api.nvim_buf_line_count(0)

	for i = current_line + 1, total_lines do
		local line_content = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		if line_content:match("^%S") then
			vim.api.nvim_win_set_cursor(0, { i, 0 })
			break
		end
	end
end

function SendToTerminal(opt)
	-- 0: send current line to buffer
	-- 1: send visual selection to buffer
	-- 2: send entire file up to and including current line to buffer

	-- extract text from current buffer
	local txt = ""
	if opt == 1 then
		vim.cmd('normal! gv"xy') -- move visual selection to x register
		txt = vim.fn.getreg("x")
		vim.api.nvim_exec2(":'>", {}) -- move cursor to last highlighted line
	elseif opt == 2 then
		local ln, _ = unpack(vim.api.nvim_win_get_cursor(0))
		local line_txts = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, ln, false)
		txt = table.concat(line_txts, "\n")
	else
		txt = vim.api.nvim_get_current_line()
	end

	-- move cursor to next non-whitespace line
	nextLine()

	-- locate terminal buffer
	local term_buf = nil
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[bufnr].buftype == "terminal" then
			term_buf = bufnr
			break
		end
	end
	if term_buf == nil then
		print("No terminal buffer found")
		return
	end

	vim.api.nvim_chan_send(vim.api.nvim_get_option_value("channel", { buf = term_buf }), txt .. "\r")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	callback = function()
		vim.schedule(function()
			vim.keymap.set("n", "<leader><leader>py", [[:lua OpenTerminalBuffer("python3")<CR>]])
			vim.keymap.set({ "v", "x" }, "<BSlash>d", [[:lua SendToTerminal(1)<CR>]])
			vim.keymap.set("n", "<BSlash>d", [[:lua SendToTerminal(0)<CR>]])
			vim.keymap.set("n", "<BSlash>aa", [[:lua SendToTerminal(2)<CR>]])
		end)
	end,
})
