--- Binds a lazy loading metatable to a module
---@param module table The module table to apply the metatable to
---@param base_path string The base path to dynamically load submodules from
---@return table The module with the lazy loading metatable applied
local function lazy_module(module, base_path)
	setmetatable(module, {
		__index = function(t, k)
			local path = base_path .. "." .. k
			local ok, mod = pcall(require, path)
			if ok then
				rawset(t, k, mod) -- Cache the loaded module
				return mod
			else
				error("Module not found: " .. path)
			end
		end,
	})
	return module
end
return lazy_module
