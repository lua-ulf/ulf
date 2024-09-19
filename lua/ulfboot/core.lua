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

---@class ulf._internal @internals

if _G.ulf then
	return _G.ulf
end

local Loader = require("ulfboot.loader")
local Config = require("ulfboot.config").setup(Loader, {})

---@class ulf
---@field api ulf.api
---@field _ ulf._internal
local ulf = {
	_ = {

		package = { loaded = require("ulfboot.package").Cache },
	},
	uv = vim and vim.uv or require("luv"),
	api = {
		-- process = {},
		init = function(opts) end,
		config = require("ulfboot.config"),
		logger = (function()
			require("ulf.log").register("ulf", Config.logging)
			---@type ulf.ILogManager
			return require("ulf.logger")
		end)(),
		initialized = false,
		loader = Loader,
	},
}
_G.ulf = ulf
Loader.setup(ulf, {})

---@class _ulf.metatable
ulf.meta = {}

ulf.meta.__index = function(t, k)
	local pack = Loader.get(k)
	rawset(t, k, pack)
	return pack
end

ulf.meta.__call = function(t, ...)
	local argv = { ... }
	print("not impl")
end

setmetatable(ulf, {
	__index = ulf.meta.__index,
	__call = ulf.meta.__call,
})

return ulf
