---@brief [[
---
---@brief ]]

---@tag ulf.loader
---@config { ["name"] = "ULF.LOADER" }
---

---@alias ulf.loader.LoaderCache table<string, {total:number, time:number, [string]:number?}?>

local string = string

---@class ulf._loader.Loader
---@field ['package'] {loaded:any}
---@field ulf ulf
local Loader = {
	---@type ulf.loader.LoaderCache
	_stats = {
		find = { total = 0, time = 0, not_found = 0 },
	},
}

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

---@class ulf._libdata
---@field available {[string]:string}
local _libdata = {}

local uv = vim and vim.uv or require("luv")
local unpack = unpack or table.unpack
-- local Config = require("ulf._loader.config")

---@return ulf.config.Packages
local function packages_list()
	---@type string[]
	local packs = {}
	for pack_name, pack_conf in pairs(Loader.Config.packages.global) do
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

--- Loads the given module path using the cache
---@param modpath string
---@param opts? {mode?: "b"|"t"|"bt", env?:table} (table|nil) Options for loading the module:
---    - mode: (string) the mode to load the module with. "b"|"t"|"bt" (defaults to `nil`)
---    - env: (table) the environment to load the module in. (defaults to `nil`)
---@see |luaL_loadfile()|
---@return function?, string? error_message
---@private
function Loader.load(modpath, opts)
	local start = uv.hrtime()
	-- Loader.track("load", start)
	-- Loader.Debug.debug_print(string.format("loader.load: %s", modpath))

	opts = opts or {}
	local elem = split(modpath)

	if (not (elem and elem[1] == "ulf")) or (elem and #elem > 1 and elem[1] == "ulf" and elem[2] == "_loader") then
		return Loader.default_loader(modpath, opts)
	else
		---@type function?, string?
		local mod, err
		-- local Package = require("ulf._loader.package")
		local mod, err = Loader.Package.loadfile(modpath)
		if not mod then
			return nil, err
		end
		return function(name)
			return mod
		end
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

Loader.get = function(k)
	local v = _libdata.available.packages[k]
	if v and v.enabled then
		return require("ulf." .. k)
	end
end

---@param opts ulf.InitOptions
Loader.stage2 = function(opts)
	-- Loader.debug("loader.stage2 ENTER")
end

---comment
---@param opts ulf.InitOptions
---@return fun(opts:ulf.InitOptions)
Loader.stage1 = function(opts)
	-- Loader.debug("loader.stage1 ENTER")
end
---@class ulfboot.loader.Options

---comment
---@param ulf ulf
---@param package ulf._loader.package
---@param config ulf.config
Loader.setup = function(ulf, package, config)
	P({
		"Loader.setup>>>>>>>>>>>>>>>",
		-- ulf = ulf,
		package = package,
	})
	assert(type(ulf) == "table", "[ulf.loader].setup: ulf must be a table")
	assert(type(package) == "table", "[ulf.loader].setup: package must be a table")
	assert(type(config) == "table", "[ulf.loader].setup: config must be a table")
	-- assert(type(opts) == "table", "[ulf._loader.loader].Loader.setup: opts must be a table")

	Loader.Package = package
	Loader.Config = config
	Loader.ulf = ulf
	return Loader
end

-- --- Prints all cache stats
-- ---@param opts? {print?:boolean}
-- ---@return LoaderStats
-- ---@private
-- function Loader._inspect(opts)
--   if opts and opts.print then
--     ---@private
--     local function ms(nsec)
--       return math.floor(nsec / 1e6 * 1000 + 0.5) / 1000 .. "ms"
--     end
--     local chunks = {} ---@type string[][]
--     ---@type string[]
--     local stats = vim.tbl_keys(Loader._stats)
--     table.sort(stats)
--     for _, stat in ipairs(stats) do
--       vim.list_extend(chunks, {
--         { "\n" .. stat .. "\n", "Title" },
--         { "* total:    " },
--         { tostring(Loader._stats[stat].total) .. "\n", "Number" },
--         { "* time:     " },
--         { ms(Loader._stats[stat].time) .. "\n", "Bold" },
--         { "* avg time: " },
--         { ms(Loader._stats[stat].time / Loader._stats[stat].total) .. "\n", "Bold" },
--       })
--       for k, v in pairs(Loader._stats[stat]) do
--         if not vim.tbl_contains({ "time", "total" }, k) then
--           chunks[#chunks + 1] = { "* " .. k .. ":" .. string.rep(" ", 9 - #k) }
--           chunks[#chunks + 1] = { tostring(v) .. "\n", "Number" }
--         end
--       end
--     end
--     vim.api.nvim_echo(chunks, true, {})
--   end
--   return Loader._stats
-- end
--
--

return Loader
