---@class ulf.config : ulf.config.ConfigOptions
local M = {}

-- use full path to module because loader is not yet active
local minilib = require("ulf.core.mods.minilib")

---@class ulf.config.PackageOption
---@field enabled boolean

---@class ulf.config.Packages
---@field async ulf.config.PackageOption
---@field core ulf.config.PackageOption
---@field doc ulf.config.PackageOption
---@field lib ulf.config.PackageOption
---@field log ulf.config.PackageOption
---@field process ulf.config.PackageOption
---@field sys ulf.config.PackageOption
---@field util ulf.config.PackageOption
---@field vim ulf.config.PackageOption

---@class ulf.config.ConfigOptions
---@field logging ulf.log.config.ConfigOptions
---@field packages {global:ulf.config.Packages}
local defaults = {

	logging = {

		logger = {
			{
				name = "ulf",
				icon = "👽",
				writer = {
					stdout = { level = "error" },
					fs = { level = "debug" },
				},
				enabled = true,
			},
		},
	},
	packages = {
		global = {
			async = { enabled = true },
			core = { enabled = true },
			doc = { enabled = true },
			lib = { enabled = true },
			log = { enabled = true },
			process = { enabled = true },
			sys = { enabled = true },
			util = { enabled = true },
			vim = { enabled = true },
		},
	},
}

---@class ulf.config.ConfigOptions
M.defaults = defaults

---@type ulf.config.ConfigOptions
local options

---@param opts? ulf.config.ConfigOptions
---@return ulf.config
function M.setup(opts)
	options = minilib.tbl_deep_extend("force", defaults, opts or {}) or {}

	return M
end

---@type ulf.config.ConfigOptions
setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return minilib.deepcopy(defaults)[key]
		end
		---@cast options ulf.config.ConfigOptions
		return options[key]
	end,
})
return M
