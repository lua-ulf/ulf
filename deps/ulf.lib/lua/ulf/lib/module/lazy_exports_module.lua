local lazy_module = require("ulf.lib.module.lazy_module")

--- Binds a lazy loading metatable to a module
---@param module table The module table to apply the metatable to
---@param export ulf.core.package.PackageExportSpec
---@param modpath string The base path to dynamically load submodules from
---@return table The module with the lazy loading metatable applied
local function lazy_exports_module(module, export, modpath)
	return setmetatable(module, {
		__name = modpath,
		__index = function(t, k)
			print(string.format("[%s].__index: k=%s", modpath, k))
			local v = rawget(t, k)
			if v then
				return v
			end

			if type(export) ~= "table" then
				return
			end

			local modules = export.modules
			if type(modules) ~= "table" then
				return
			end

			local prefix = export.prefix and ("." .. export.prefix .. ".") or "."

			--- v is either
			--- spec = {
			---   enabled = true
			--- }
			--- or a boolean or nil
			---@type ulf.core.package.PackageModuleSpec
			v = modules[k]

			---@type string
			local destpath = modpath .. prefix .. k

			print(string.format("[%s].__index: destpath=%s prefix=%s value=%s", modpath, destpath, prefix, v))
			if v then
				local ok, mod = pcall(require, destpath) ---@diagnostic disable-line: no-unknown
				if ok then
					return mod
				else
					-- no init.lua in destination module
					-- return an empty table
					return lazy_module({}, destpath)
				end
			end
		end,
	})
end
return lazy_exports_module
