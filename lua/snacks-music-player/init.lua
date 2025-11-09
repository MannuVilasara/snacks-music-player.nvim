local M = {}

-- Default configuration
M.config = {
	width = 62,
	height = 14,
	backdrop = 60,
	update_interval = 1000,
	progress_bar_width = 38,
	colors = {
		border = "FloatBorder",
		title = "Title",
		artist = "Comment",
		progress_bar = "String",
		time = "Number",
		controls = "Special",
		status_playing = "String",
		status_paused = "WarningMsg",
	},
}

M.win = nil
M.timer = nil

-- Get current track info from playerctl
function M.get_track_info()
	local info = {}

	-- Get metadata
	local commands = {
		artist = "playerctl metadata artist 2>/dev/null",
		title = "playerctl metadata title 2>/dev/null",
		album = "playerctl metadata album 2>/dev/null",
		status = "playerctl status 2>/dev/null",
		position = "playerctl position 2>/dev/null",
		length = "playerctl metadata mpris:length 2>/dev/null",
	}

	for key, cmd in pairs(commands) do
		local handle = io.popen(cmd)
		if handle then
			local result = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
			handle:close()
			info[key] = result ~= "" and result or "Unknown"
		end
	end

	-- Convert position and length to seconds
	if info.position and info.position ~= "Unknown" then
		info.position_sec = tonumber(info.position) or 0
	end

	if info.length and info.length ~= "Unknown" then
		-- mpris:length is in microseconds
		info.length_sec = tonumber(info.length) / 1000000 or 0
	end

	return info
end

-- Format time in mm:ss
function M.format_time(seconds)
	if not seconds or seconds == 0 then
		return "0:00"
	end
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%d:%02d", mins, secs)
end

-- Create progress bar
function M.create_progress_bar(current, total, width)
	width = width or M.config.progress_bar_width
	if not current or not total or total == 0 then
		return string.rep("-", width)
	end

	local progress = math.min(current / total, 1)
	local filled = math.floor(progress * (width - 1))
	local empty = width - 1 - filled

	return string.rep("━", filled) .. "╸" .. string.rep("─", empty)
end

-- Helper function to truncate string if too long
local function truncate_string(str, max_width)
	local len = vim.fn.strwidth(str)
	if len <= max_width then
		return str
	end
	-- Truncate and add ellipsis
	local truncated = ""
	local current_len = 0
	for i = 1, #str do
		local char = str:sub(i, i)
		local char_width = vim.fn.strwidth(char)
		if current_len + char_width + 3 > max_width then -- +3 for "..."
			break
		end
		truncated = truncated .. char
		current_len = current_len + char_width
	end
	return truncated .. "..."
end

-- Helper function to pad string to exact width (center align)
local function pad_center(str, width)
	local len = vim.fn.strwidth(str)
	if len >= width then
		return str:sub(1, width)
	end
	local padding_left = math.floor((width - len) / 2)
	local padding_right = width - len - padding_left
	return string.rep(" ", padding_left) .. str .. string.rep(" ", padding_right)
end

-- Update the player UI
function M.update_ui()
	if not M.win or not M.win:valid() then
		return
	end

	local info = M.get_track_info()
	local lines = {}
	local w = M.config.width - 2 -- Inner width (excluding borders)

	-- Top border
	table.insert(lines, "╔" .. string.rep("═", w) .. "╗")
	table.insert(lines, "║" .. string.rep(" ", w) .. "║")

	-- Track info
	local title = info.title ~= "Unknown" and info.title or "No Track"
	local artist = info.artist ~= "Unknown" and info.artist or "Unknown Artist"
	local track = title .. " - " .. artist
	-- Truncate if too long to fit in the window
	track = truncate_string(track, w)
	table.insert(lines, "║" .. pad_center(track, w) .. "║")

	table.insert(lines, "║" .. string.rep(" ", w) .. "║")
	table.insert(lines, "╠" .. string.rep("═", w) .. "╣")
	table.insert(lines, "║" .. string.rep(" ", w) .. "║")

	-- Progress
	local curr = M.format_time(info.position_sec)
	local total = M.format_time(info.length_sec)
	local bar = M.create_progress_bar(info.position_sec, info.length_sec)
	local icon = info.status == "Playing" and "▶" or info.status == "Paused" and "⏸" or "⏹"

	local prog = curr .. " " .. bar .. " " .. total .. " " .. icon
	table.insert(lines, "║" .. pad_center(prog, w) .. "║")

	table.insert(lines, "║" .. string.rep(" ", w) .. "║")
	table.insert(lines, "╠" .. string.rep("═", w) .. "╣")
	table.insert(lines, "║" .. string.rep(" ", w) .. "║")

	-- Controls
	local ctrl = "[p] Play/Pause   [n] Next   [b] Previous   [q] Quit"
	table.insert(lines, "║" .. pad_center(ctrl, w) .. "║")

	table.insert(lines, "║" .. string.rep(" ", w) .. "║")
	table.insert(lines, "╚" .. string.rep("═", w) .. "╝")

	-- Update buffer
	vim.bo[M.win.buf].modifiable = true
	vim.api.nvim_buf_set_lines(M.win.buf, 0, -1, false, lines)
	vim.bo[M.win.buf].modifiable = false

	-- Apply syntax highlighting
	local ns = vim.api.nvim_create_namespace("music_player")
	vim.api.nvim_buf_clear_namespace(M.win.buf, ns, 0, -1)

	-- Highlight borders
	for i = 0, #lines - 1 do
		vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerBorder", i, 0, -1)
	end

	-- Highlight track info (line 2, 0-indexed)
	vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerTitle", 2, 0, -1)

	-- Highlight progress bar (line 6)
	local prog_line = 6
	local prog_text = lines[prog_line + 1]
	-- Find the position of the progress bar
	local bar_start = prog_text:find("━") or prog_text:find("─")
	local bar_end = prog_text:find(icon, 1, true)
	
	if bar_start and bar_end then
		-- Highlight time before progress bar
		vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerTime", prog_line, 0, bar_start - 1)
		-- Highlight progress bar
		vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerProgress", prog_line, bar_start - 1, bar_end - 1)
		-- Highlight time after progress bar
		vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerTime", prog_line, bar_end - 1, bar_end + 5)
		-- Highlight status icon
		local status_hl = info.status == "Playing" and "MusicPlayerPlaying" or "MusicPlayerPaused"
		vim.api.nvim_buf_add_highlight(M.win.buf, ns, status_hl, prog_line, bar_end + 5, -1)
	end

	-- Highlight controls (line 10)
	vim.api.nvim_buf_add_highlight(M.win.buf, ns, "MusicPlayerControls", 10, 0, -1)
end

-- Toggle music player UI
function M.toggle()
	if M.win and M.win:valid() then
		M.close()
		return
	end

	local snacks_ok, Snacks = pcall(require, "snacks")
	if not snacks_ok then
		vim.notify("snacks.nvim is required for snacks-music-player", vim.log.levels.ERROR)
		return
	end

	M.win = Snacks.win({
		position = "float",
		width = M.config.width,
		height = M.config.height,
		border = "none",
		title = "",
		zindex = 50,
		backdrop = M.config.backdrop,
		bo = {
			modifiable = true,
			readonly = false,
		},
		wo = {
			winblend = 0,
			winhighlight = "Normal:Normal",
		},
		keys = {
			q = function()
				M.close()
			end,
			p = function()
				vim.fn.system("playerctl play-pause")
				vim.defer_fn(function()
					M.update_ui()
				end, 100)
			end,
			n = function()
				vim.fn.system("playerctl next")
				vim.defer_fn(function()
					M.update_ui()
				end, 500)
			end,
			b = function()
				vim.fn.system("playerctl previous")
				vim.defer_fn(function()
					M.update_ui()
				end, 500)
			end,
		},
	})

	-- Initial update
	M.update_ui()

	-- Auto-update every interval for real-time progress
	M.timer = vim.loop.new_timer()
	M.timer:start(
		M.config.update_interval,
		M.config.update_interval,
		vim.schedule_wrap(function()
			M.update_ui()
		end)
	)
end

-- Close music player
function M.close()
	if M.timer then
		M.timer:stop()
		M.timer:close()
		M.timer = nil
	end

	if M.win and M.win:valid() then
		M.win:close()
		M.win = nil
	end
end

-- Player controls (can be called from keybindings)
function M.play_pause()
	vim.fn.system("playerctl play-pause")
end

function M.next()
	vim.fn.system("playerctl next")
end

function M.previous()
	vim.fn.system("playerctl previous")
end

-- Setup function for configuration
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	
	-- Define custom highlight groups
	vim.api.nvim_set_hl(0, "MusicPlayerBorder", { link = M.config.colors.border })
	vim.api.nvim_set_hl(0, "MusicPlayerTitle", { link = M.config.colors.title })
	vim.api.nvim_set_hl(0, "MusicPlayerArtist", { link = M.config.colors.artist })
	vim.api.nvim_set_hl(0, "MusicPlayerProgress", { link = M.config.colors.progress_bar })
	vim.api.nvim_set_hl(0, "MusicPlayerTime", { link = M.config.colors.time })
	vim.api.nvim_set_hl(0, "MusicPlayerControls", { link = M.config.colors.controls })
	vim.api.nvim_set_hl(0, "MusicPlayerPlaying", { link = M.config.colors.status_playing })
	vim.api.nvim_set_hl(0, "MusicPlayerPaused", { link = M.config.colors.status_paused })
end

return M
