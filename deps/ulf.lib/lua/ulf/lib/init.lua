---@class ulf.lib
local M = {

	package = {
		meta = require("ulf.lib.package"),
		export = {

			modules = {
				string = { enabled = true },
				table = { enabled = true },
				func = { enabled = true },
				types = { enabled = true },
				module = { enabled = true },
				fs = { enabled = true },
				error = { enabled = true },
			},
		},
	},
}

return M
