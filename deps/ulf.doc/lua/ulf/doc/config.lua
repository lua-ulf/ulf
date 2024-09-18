---@class ulf.doc.config
local M = {}
local uv = vim and vim.uv or require("luv")

---@type ulf
local minilib = require("ulf.core.mods.minilib")
local deps_root = "~/.cache/ulf/build/doc"

---comment
---@param ... string
---@return string
local path = function(...)
	local argv = { ... } or {}
	for index, value in ipairs(argv) do
	end
end
---@class table<K, V>: { [K]: V }
---
---@class ulf.doc.config.BackendOptions
---@field enabled boolean Enables or disables backend
---@field plugin_path string Path to the plugin, if not set the default path is used.
---@field logging {level:string} Logging options fro the backend
---@field description string Dscription for this backend
---
---@class ulf.doc.config.Backends
---@field tree_sitter_lua ulf.doc.BackendOptions
---@field mini_doc ulf.doc.BackendOptions

--- Default settings for the module ulf.doc
---
---@class ulf.doc.config.ConfigOptions
---@field backends ulf.doc.config.Backends
---@field logging ulf.log.config.ConfigOptions
local defaults = {
	logging = {
		logger = {
			{
				name = "doc",
				icon = " ",
				writer = {
					stdout = { level = "error" },
					fs = { level = "debug" },
				},
				enabled = true,
			},
			{
				name = "gendocs",
				icon = " ",
				writer = {
					stdout = { level = "error" },
					fs = { level = "debug" },
				},
				enabled = true,
			},
		},
	},
	backends = {
		tree_sitter_lua = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/tree-sitter-lua
			plugin_path = "",
			logging = {
				level = "debug",
			},
			description = [[Uses tree-sitter-lua to parse LuaCATS annotations and generates a vimdoc.]],
		},
		mini_doc = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/mini.doc
			plugin_path = "",
			logging = {
				level = "debug",
			},
			description = [[Generate Neovim help files]],
		},
		luacats = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/mini.doc
			plugin_path = "",
			logging = {
				level = "debug",
			},
			description = [[Parses LuaCATS annotations from any Lua file and generates customized output files]],
		},
		md_helptags = {
			enabled = true,
			-- path to the plugin, if empty or nil the default path is used
			-- $HOME/.cache/ulf/build/doc/mini.doc
			plugin_path = "",
			logging = {
				level = "debug",
			},
			description = [[Injects code blocks into markdown (see LazyVim)]],
		},
	},
}

M.defaults = defaults

M.backends = function()
	return minilib.tbl_keys(M.options.backends)
end

---@type ulf.doc.config.ConfigOptions
M.options = {}

---@param opts? ulf.doc.config.ConfigOptions
function M.setup(opts)
	local options = minilib.tbl_deep_extend("force", defaults, opts or {}) or {}

	M.options = options

	return options
end

return M
