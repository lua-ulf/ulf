---@class tests.ulf.core.package.Cache @Handles caching of registered packages.
---@field packages {[string]:any} A table storing cached packages.
local Cache = {
	packages = {},
}
setmetatable(Cache, {
	__index = function(t, k)
		local packages = rawget(t, "packages")
		if packages[k] then
			return packages[k]
		end
	end,
})
--- Registers a package into the cache.
---@param modpath string The module path.
---@param pack table The package to be registered.
function Cache.register(modpath, pack)
	if not Cache.packages[modpath] then
		Cache.packages[modpath] = pack
	end
end

--- Unregisters a package from the cache.
---@param modpath string The module path.
function Cache.unregister(modpath)
	if Cache.packages[modpath] then
		Cache.packages[modpath] = nil
	end
end

return Cache
