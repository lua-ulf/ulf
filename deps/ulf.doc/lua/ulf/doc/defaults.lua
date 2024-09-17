local uv = vim and vim.uv or require("luv")

---@type ulf
local ulf = require("ulf")
local deps_root = "~/.cache/ulf/build/doc"

---comment
---@param ... string
---@return string
local path = function(...)
	local argv = { ... } or {}
	for index, value in ipairs(argv) do
	end
end

--- Default settings for the module ulf.doc
---
---@class ulf.doc.Defaults
local defaults = {
	backends = {
		["tree-sitter-lua"] = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/tree-sitter-lua
			plugin_path = "",
			logging = {
				level = "debug",
			},
		},
		["mini.doc"] = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/mini.doc
			plugin_path = "",
			logging = {
				level = "debug",
			},
		},
	},
}

return defaults
