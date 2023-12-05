local M = {}

local config = {
	enabled = true,
	highlight = {
		foreground = "#333333",
		background = nil,
	},
	mode = "relative", -- relative, absolute
	style = "normal", -- gradient, inverted-gradient
}

function M.set(user_config)
	if not user_config or type(user_config) ~= "table" then
		return config
	end

	config = vim.tbl_deep_extend("force", config, user_config)
	return config
end

return M
