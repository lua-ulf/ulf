---@brief [[
--- ulf.core is the core library for the ULF project. It contains a superset of
--- luvit@core and some custom functions and objects.
---
---
---@brief ]]

---@tag ulf.core
---@config { ["name"] = "ULF.CORE" }
---
---@class ulf.core
---@field argsutil ulf.core.argsutil
---@field json ulf.core.json
---@field minilib ulf.core.minilib
local M = {

	package = {
		name = "lua-ulf/ulf.core@0.1.0",
		version = "0.1.0",
	},
	modules = {
		json = true,
		argsutil = true,
		minilib = true,
	},
}
setmetatable(M, {
	__index = function(t, k)
		local modules = rawget(t, "modules")
		---@type any
		local v = modules[k]
		if v then
			P("ulf.core.__index", v, k)
			local ok, mod = pcall(require, "ulf.core.mods." .. k) ---@diagnostic disable-line: no-unknown
			P(ok, mod)
			if ok then
				rawset(t, k, mod)
				return mod
			end
		end
	end,
})
return M
