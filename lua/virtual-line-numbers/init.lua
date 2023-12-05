local M = {}

local api = vim.api

local autocmd_id
local eff_config
local AUGROUP = api.nvim_create_augroup("VirtualLineNumbersGroup", { clear = true })
local NAMESPACE = api.nvim_create_namespace("VirtualLineNumbers")
local config = require("virtual-line-numbers.config")

local command = function(name, callback, opts)
	api.nvim_create_user_command(name, callback, opts or {})
end

local function clear_virt_text()
	api.nvim_buf_clear_namespace(0, NAMESPACE, 0, -1)
end

local function setup_autocmd()
	autocmd_id = api.nvim_create_autocmd("CursorMoved", {
		group = AUGROUP,
		callback = function()
			require("virtual-line-numbers").add_relative_numbers_virt_text()
		end,
	})
end

M.disable = function()
	if autocmd_id ~= nil then
		api.nvim_del_autocmd(autocmd_id)
		clear_virt_text()
	end
end

M.enable = function()
	if autocmd_id == nil then
		setup_autocmd()
	end
end

local function add_virt_text(line, cursor_row)
	local number

	if eff_config.mode == "relative" then
		number = math.abs(cursor_row - line)
	else
		number = line + 1
	end

	api.nvim_buf_set_extmark(0, NAMESPACE, line, 0, {
		virt_text = {
			{
				tostring(number),
				"VirtualLineNumbers",
			},
		},
		virt_text_pos = "eol",
		hl_mode = "combine",
		priority = 1,
	})
end

M.add_relative_numbers_virt_text = function()
	clear_virt_text()
	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	for line, _ in ipairs(lines) do
		add_virt_text(line, cursor_row - 1)
	end
end

M.start = function()
	if eff_config.enabled then
		M.enable()
	else
		M.disable()
	end
end

local function setup()
	api.nvim_set_hl(
		0,
		"VirtualLineNumbers",
		{ fg = eff_config.highlight.foreground, bg = eff_config.highlight.background }
	)
	command("VirtualLineNumbersToggle", function()
		eff_config = config.set({ enabled = not eff_config.enabled })
		M.start()
	end)
	command("VirtualLineNumbersEnable", M.enable)
	command("VirtualLineNumbersDisable", M.disable)
end

---Entry point for this plugin
---@param user_config table
function M.setup(user_config)
	eff_config = config.set(user_config)
	setup()
	M.start()
end

return M
