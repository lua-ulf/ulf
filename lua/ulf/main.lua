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
---@field config ulf.config
---@field get_loader fun(ulf:ulf,package:ulf.core.package,config:ulf.config)
---@field package ulf.core.package
---@field debug ulf.core.debug
---@field inspect ulf.core.inspect

---@class ulf._internal @internals

if _G.ulf then
	return _G.ulf
end
---comment
---@param opts ulf.InitOptions
---@return ulf
local function init(opts)
	local Config = opts.config.setup({})

	-- local function register_logger()
	-- 	require("ulf.log").register("ulf", Config.logging)
	-- 	---@type ulf.ILogManager
	-- 	local Logger = require("ulf.logger")
	-- 	return Logger
	-- end

	---@class ulf
	---@field api ulf.api
	---@field _ ulf._internal
	local ulf = {
		_ = {

			package = { loaded = opts.package.Cache },
		},
		uv = vim and vim.uv or require("luv"),
		api = {
			-- process = {},
			init = function(opts) end,
			config = Config,
			-- logger = register_logger(),
			logger = (function()
				require("ulf.log").register("ulf", Config.logging)
				---@type ulf.ILogManager
				return require("ulf.logger")
			end)(),
			initialized = false,
		},
	}
	_G.ulf = ulf
	ulf.api.loader = opts.get_loader(ulf, opts.package, opts.config)

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
	ulf.api.loader.init()

	ulf.api.logger.info("ulf loaded")
	return setmetatable(ulf, {
		__index = ulf.meta.__index,
		__call = ulf.meta.__call,
	})
end

local function assert_init_options(opts)
	assert(type(opts) == "table", "[ulf.main].assert_init_options: opts must be a table")
	assert(type(opts.config) == "table", "[ulf.main].assert_init_options: opts.config must be a table")
	assert(type(opts.get_loader) == "function", "[ulf.main].assert_init_options: opts.get_loader must be a function")
	assert(type(opts.debug) == "table", "[ulf.main].assert_init_options: opts.debug must be a table")
	assert(type(opts.package) == "table", "[ulf.main].assert_init_options: opts.package must be a table")
	assert(type(opts.inspect) == "table", "[ulf.main].assert_init_options: opts.inspect must be a table")
end

return {
	---@param opts ulf.InitOptions
	---@return ulf
	init = function(opts)
		assert_init_options(opts)
		opts.debug._G()
		return init(opts)
	end,
}
