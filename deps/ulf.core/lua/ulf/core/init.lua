---@brief [[
--- ulf.core is the core library for the ULF project. It contains a superset of
--- luvit@core and some custom functions and objects.
---
---
---@brief ]]

---@tag ulf.core
---@config { ["name"] = "ULF.CORE" }
---
local Package = require("ulf.core.mods.package")

---@class ulf.core.exports : ulf.Package
---@field argsutil ulf.core.argsutil
---@field debug ulf.core.debug
---@field json ulf.core.json
---@field inspect ulf.core.inspect
---@field package ulf.core.package
---@field minilib ulf.core.minilib
local M = { ---@diagnostic disable-line: missing-fields

	package = {
		meta = require("ulf.core.package"),
		export = {

			prefix = "mods",
			modules = {
				json = true,
				argsutil = true,
				debug = true,
				minilib = true,
				package = true,
				inspect = true,
			},
		},
	},
}

return M
-- return setmetatable(M, {
-- 	__index = function(t, k)
-- 		local package = rawget(t, "package")
-- 		local modules = rawget(package, "modules")
-- 		---@type any
-- 		local v = modules[k]
-- 		if v then
-- 			-- P("ulf.core.__index", v, k)
-- 			local ok, mod = pcall(require, "ulf.core.mods." .. k) ---@diagnostic disable-line: no-unknown
-- 			-- P(ok, mod)
-- 			if ok then
-- 				rawset(t, k, mod)
-- 				return mod
-- 			end
-- 		end
-- 	end,
-- })
