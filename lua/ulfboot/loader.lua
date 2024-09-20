---@brief [[
---
---@brief ]]

---@tag ulf.loader
---@config { ["name"] = "ULF.LOADER" }
---

---@alias ulf.loader.LoaderCache table<string, {total:number, time:number, [string]:number?}?>

local string = string

---@class ulf.loader
---@field ['package'] {loaded:any}
---@field ulf ulf
local Loader = {
	---@type ulf.loader.LoaderCache
	_stats = {
		find = { total = 0, time = 0, not_found = 0 },
	},
	debug = function(msg)
		local inspect = require("ulfboot.inspect")

		if type(msg) ~= "string" then
			msg = inspect(msg)
		end
		io.write(msg .. "\n")
		io.flush()
	end,
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
local Config = require("ulfboot.config")

---@return ulf.config.Packages
local function packages_list()
	---@type string[]
	local packs = {}
	for pack_name, pack_conf in pairs(Config.packages.global) do
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
	Loader.track("load", start)

	opts = opts or {}
	local elem = split(modpath)

	if not (elem and elem[1] == "ulf") then
		return Loader.default_loader(modpath, opts)
	else
		---@type function?, string?
		local mod, err
		local Package = require("ulfboot.package")
		local mod, err = Package.loadfile(modpath)
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
---@param opts ulfboot.loader.Options
Loader.setup = function(ulf, opts)
	assert(ulf, "Loader.setup: ulf must not be nil")
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
