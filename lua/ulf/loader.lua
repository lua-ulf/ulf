---@brief [[
---
---@brief ]]

---@tag ulf.loader
---@config { ["name"] = "ULF.LOADER" }
---

---@alias ulf.loader.LoaderCache table<string, {total:number, time:number, [string]:number?}?>

local string = string

---@class ulf.loader
---@field Config ulf.config
---@field ulf ulf
local Loader = {
	---@type ulf.loader.LoaderCache
	_stats = {
		find = { total = 0, time = 0, not_found = 0 },
	},
}

---comment
---@param inputstr string
---@param sep? string
---@return string[]
local function split(inputstr, sep)
	if sep == nil then
		sep = "%."
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

---@class _libdata
---@field  available {packages:{[string]:ulf.config.PackageOption}}
local _libdata = {}

local uv = vim and vim.uv or require("luv")
local unpack = unpack or table.unpack
-- local Config = require("ulf._loader.config")

---@return ulf.config.Packages
local function packages_list()
	---@type {[string]:table}
	local packs = {}
	for pack_name, pack_conf in
		pairs(Loader.Config.packages.global --[[ @as {[string]:table}  ]])
	do
		if pack_conf.enabled then
			packs[pack_name] = pack_conf
		end
	end
	return packs
end

_libdata.available = setmetatable({}, {
	__index = function(t, k)
		if k == "packages" then
			local v = packages_list()
			if not v then
				error("error getting packages")
			end

			rawset(t, k, v)

			return v
		end
	end,
})

--- Tracks the time spent in a function
---@private
function Loader.track(stat, start)
	Loader._stats[stat] = Loader._stats[stat] or { total = 0, time = 0 }
	Loader._stats[stat].total = Loader._stats[stat].total + 1
	Loader._stats[stat].time = Loader._stats[stat].time + uv.hrtime() - start
end

Loader.default_loader = nil

local function symbol_full_name(mod, sym)
	return string.format("[ulf.%s].%s", mod, sym)
end

--- Loads the given module path using the cache
---@param modpath string
---@param opts? {mode?: "b"|"t"|"bt", env?:table} (table|nil) Options for loading the module:
---    - mode: (string) the mode to load the module with. "b"|"t"|"bt" (defaults to `nil`)
---    - env: (table) the environment to load the module in. (defaults to `nil`)
---@return function?, string? error_message
---@private
function Loader.load(modpath, opts)
	print(symbol_full_name("loader.Load", "load") .. " called with: " .. modpath)
	-- Loader.ulf.api.logger.debug("test")
	local start = uv.hrtime()
	-- Loader.track("load", start)
	-- Loader.Debug.debug_print(string.format("loader.load: %s", modpath))

	opts = opts or {}

	---list of lua module path elements
	---TODO: rewrite using fp with filter
	---@type string[]
	-- local elem = split(modpath)
	local is_ulf_package, elem = Loader.Package.is_ulf_package(modpath)

	if is_ulf_package then
		-- if (not (elem and elem[1] == "ulf")) or (elem and #elem > 1 and elem[1] == "ulf" and elem[2] == "_loader") then
		---@type function?, string?
		local mod, err
		-- local Package = require("ulf._loader.package")
		local mod, err = Loader.Package.load(modpath, #elem == 2)
		if not mod then
			return nil, err
		end
		return function(name)
			return mod
		end
	else
		print(symbol_full_name("loader.Load", "load") .. " redirect to default_loader: " .. modpath)
		return Loader.default_loader(modpath, opts)
	end
end

Loader.init = function()
	local loaders = package.loaders or package.searchers

	-- Loader.debug(string.format("loader.init: called"))
	Loader.default_loader = loaders[2]

	-- Loader.debug("default_loader", Loader.default_loader)
	-- table.insert(package.loaders, 2, Loader.ulf_load)
	loaders[2] = Loader.load
end

---comment
---@param k string
---@return table?
Loader.get = function(k)
	local v = _libdata.available.packages[k]
	if v and v.enabled then
		return require("ulf." .. k)
	end
end

---@param opts ulf.InitOptions
Loader.stage2 = function(opts)
	print("loader.stage2 ENTER")
end

---comment
---@param opts ulf.InitOptions
---@return fun(opts:ulf.InitOptions)
Loader.stage1 = function(opts)
	print("loader.stage1 ENTER")
	return Loader.stage2
end
---@class ulfboot.loader.Options

---comment
---@param ulf ulf
---@param package ulf.core.package
---@param config ulf.config
Loader.setup = function(ulf, package, config)
	assert(type(ulf) == "table", "[ulf.loader].setup: ulf must be a table")
	assert(type(package) == "table", "[ulf.loader].setup: package must be a table")
	assert(type(config) == "table", "[ulf.loader].setup: config must be a table")

	Loader.Package = package
	Loader.Config = config
	Loader.ulf = ulf
	return Loader
end

return Loader
