---@brief [[
--- ulf.doc is a documentation library for Lua/Neovim and is part of
--- the ULF project.
---@brief ]]

---@tag ulf.doc
---@config { ["name"] = "Introduction" }
---
---@class ulf.doc
local M = {

	package = {
		meta = {

			name = "lua-ulf/ulf.doc@0.1.0",
			version = "0.1.0",
		},
	},
	setup = require("ulf.doc.config").setup,
}

return M
