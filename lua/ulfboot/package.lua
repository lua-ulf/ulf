local M = {}
---@class ulf.package.Meta
---@field name string
---@field version string
---@field description string
---@field license string
---@field homepage string
---@field tags string[]
---@field author string
---@field contributors string[]
---@field dependencies string[]
---@field files string[]
local Meta = {}

local minilib = require("ulf.core.mods.minilib")

---@class MetaSpec
M.MetaDefaults = {}

---comment
---@param spec MetaSpec
---@return ulf.package.Meta
function Meta.new(spec)
	local self = setmetatable({}, { __index = Meta })

	for key, value in pairs(spec) do
		self[key] = value
	end
	return self
end

---@class ulf.package.Cache
---@field packages {[string]:any}
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

function Cache.register(modpath, pack)
	if not Cache.packages[modpath] then
		Cache.packages[modpath] = pack
	end
end
function Cache.unregister(modpath)
	if Cache.packages[modpath] then
		Cache.packages[modpath] = nil
	end
end

---@class ulf.package.Package
---@field modpath string
---@field module any
---@field meta ulf.package.Meta
local Package = {}

---@type ulf.package.Package
M.Package = Package

---@class ulf.package.PackageSpec
M.PackageDefaults = {}

---comment
---@param modpath string path to index
---@param opts? {searchpath:fun(p:string,list:string[])?}
---@return ulf.package.Package
function Package.new(modpath, opts)
	opts = opts or {}
	local self = setmetatable({}, { __index = Package })
	local searchpath = opts.searchpath or package.searchpath

	local path, msg = searchpath(modpath, package.path)
	if not path then
		error("Package.new: unable to find package path for '" .. tostring(modpath) .. "'")
	end
	print(string.format("Package.path=%s", path))
	self.path = path
	self.modpath = modpath
	self.meta = Meta.new(self)

	return self
end

-- call package setup if setup func is provided
function Package:setup()
	if type(pack.setup) == "function" then
		-- ---TODO: user config
		-- local conf = pack.setup()
		-- P(conf.logging)
		-- register_logger(name, pack, conf.logging)
	end
end

---@param modpath string
---@param opts? {mode?: "b"|"t"|"bt", env?:table} (table|nil) Options for loading the module:
function Package.loadfile(modpath, opts)
	local pack = Package.new(modpath)
	local module = loadfile(pack.path)
	P(module)

	if not module then
		return nil, "Error loading package '" .. tostring(modpath) .. "'"
	end

	pack.module = module()
	local name = modpath:match("ulf%.(%w+)%.*.*")
	Cache.register(name, pack)
	return pack.module
end

M.Cache = Cache
M.loadfile = Package.loadfile
M.new = Package.new
return M
