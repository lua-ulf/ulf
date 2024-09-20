---@class ulf.api
---@field config ulf.config
---@field init fun(opts:ulf.InitOptions)
---@field initialized boolean This flag is set once the init() function has been called.
---@field loader? ulf.loader
---@field logger ulf.ILogManager References to all LogMamangers
---@field process? ulf.GlobalProcess
---
---@class ulf.modules
---@field async ulf.async
---@field core ulf.core
---@field doc ulf.doc
---@field lib ulf.lib
---@field log ulf.log
---@field process ulf.process
---@field sys ulf.sys
---@field test ulf.test
---@field util ulf.util
---@field vim ulf.vim

---@class ulf.logger
---@field uv uv
---@field root ulf.ILogManager The global LogMamanger
---@field child {[string]:ulf.ILogManager} LogMamangers for packages

---@class ulf.InitOptions
---@field dev? boolean set development mode (default off)
---@field loader ulf.Loader

---@class ulf._internal @internals

if _G.ulf then
	return _G.ulf
end
---comment
---@param opts ulf.InitOptions
---@return ulf
local function init(opts)
	local Config = opts.loader.Config.setup({})

	---@class ulf
	---@field api ulf.api
	---@field _ ulf._internal
	local ulf = {
		_ = {

			package = { loaded = opts.loader.Package.Cache },
		},
		uv = vim and vim.uv or require("luv"),
		api = {
			-- process = {},
			init = function(opts) end,
			config = Config,
			logger = (function()
				require("ulf.log").register("ulf", Config.logging)
				---@type ulf.ILogManager
				return require("ulf.logger")
			end)(),
			initialized = false,
		},
	}
	_G.ulf = ulf
	ulf.api.loader = opts.loader.get_loader(ulf, opts.loader.Package, opts.loader.Config)

	---@class _ulf.metatable
	ulf.meta = {}

	ulf.meta.__index = function(t, k)
		local pack = ulf.api.loader.get(k)
		rawset(t, k, pack)
		return pack
	end

	ulf.meta.__call = function(t, ...)
		local argv = { ... }
		print("not impl")
	end
	ulf.api.loader.init(opts)

	return setmetatable(ulf, {
		__index = ulf.meta.__index,
		__call = ulf.meta.__call,
	})
end

local function assert_init_options(opts)
	assert(type(opts.loader) == "table", "[ulf.main].assert_init_options: opts.loader must be a table")
	assert(type(opts.loader.Config) == "table", "[ulf.main].assert_init_options: opts.loader.Config must be a table")
	assert(
		type(opts.loader.get_loader) == "function",
		"[ulf.main].assert_init_options: opts.loader.get_loader must be a function"
	)
	assert(type(opts.loader.Debug) == "table", "[ulf.main].assert_init_options: opts.loader.Debug must be a table")
	assert(type(opts.loader.Package) == "table", "[ulf.main].assert_init_options: opts.loader.Package must be a table")
	assert(type(opts) == "table", "[ulf._loader.loader].Loader.setup: opts must be a table")
end

return {
	---@param opts ulf.InitOptions
	---@return ulf
	init = function(opts)
		assert_init_options(opts)
		opts.loader.Debug._G()
		return init(opts)
	end,
}
