local M = {}
local Severity = require("ulf.log.severity")

M.logging_defaults = {

	logger = {
		{
			name = "vim",
			icon = " ",
			writer = {
				stdout = { level = Severity.levels.ERROR },
				fs = { level = Severity.levels.DEBUG },
			},
			enabled = true,
		},
		{
			name = "spawn",
			icon = "󰼢 ",
			writer = {
				stdout = { level = Severity.levels.ERROR },
				fs = { level = Severity.levels.DEBUG },
			},
			enabled = true,
		},
	},
}

return M
