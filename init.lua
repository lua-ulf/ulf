---@brief [[
--- `ULF` is a lightweight, modular library for `Lua`, `LuaJIT`, and `Neovim`,
--- offering useful modules for common development tasks. The goal of `ULF` is to
--- provide versatile modules that can be used across various environments, whether
--- in `Neovim` or standard `Lua`, without imposing any specific constraints or
--- dependencies.
---
---@brief ]]

---@tag ulf
---@config { ["name"] = "INTRODUCTION" }
---

local uv = vim and vim.uv or require("luv")
local unpack = unpack or table.unpack
require("ulf.util.debug")._G()
local ffi = require("ffi")
local minilib = require("ulf.core").minilib
local dir_exists = minilib.dir_exists
local file_exists = minilib.file_exists
local joinpath = minilib.joinpath
P(minilib)

local path_sep = ffi.os == "Windows" and "\\" or "/"

---@class ulf.Config
local defaults = {

	logging = {

		logger = {
			{
				name = "ulf",
				icon = "👽",
				writer = {
					stdout = { level = "error" },
					fs = { level = "debug" },
				},
				enabled = true,
			},
		},
	},
}

local init_logger = function(ulf)
	require("ulf.log").register("ulf", defaults.logging)
	---@type ulf.ILogManager
	ulf.logger.root = require("ulf.logger")
end

local register_logger = function(name, mod, config)
	local mod_name = "ulf." .. name
	require("ulf.log").register(mod_name, config)
	ulf.logger.child[name] = require(mod_name .. ".logger")
end

local function assert_module_interface(mod)
	assert(type(mod) == "table", "validate_module_interface: expect mod to be a table")
	assert(type(mod.package) == "table", "validate_module_interface: expect mod.package to be a table")
end
---@return {[string]:function}
local function packages_list()
	local packs = {}
	if file_exists(".gitignore") and dir_exists("deps") then
		local pack_dir = uv.fs_scandir("deps")

		while true do
			local name = uv.fs_scandir_next(pack_dir)
			if not name then
				break
			end
			local match = string.match(name, "^ulf%.(.*)$")
			if match then
				packs[match] = function()
					local package_path = joinpath("deps", name, "package.lua")
					if not minilib.file_exists(package_path) then
						error("invalid package: " .. tostring(name) .. ", missing package.lua")
					end
					local init_path = joinpath("deps", name, "lua", "ulf", match, "init.lua")
					local package = loadfile(package_path)()
					local module = loadfile(init_path)()

					return setmetatable({
						module = module,
						package = package,
						setup = module.setup and module.setup,
					}, {

						__index = function(t, k)
							local v = module[k]
							if v then
								rawset(t, k)
								return v
							end
						end,
					})
				end
			end
		end
	else
	end
	return packs
end

---@class ulf.packages
---@field packages {[string]:function}
local loader = setmetatable({}, {
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

local packages = setmetatable({}, {
	__index = function(t, k)
		local v = loader.packages[k]
		if v then
			rawset(t, k, v)
			return v
		end
	end,
})

---@type ulf
local ulf = {
	initialized = false,
	logger = {
		child = {},
		root = {},
	},
} ---@diagnostic disable-line: missing-fields
_G.ulf = ulf

-- ---comment
-- ---@param k string
-- local function get(t, k)
-- 	ulf.logger.debug("ulf.__index: get(" .. tostring(k)(")"))
-- 	local v = packages[k]
--
-- 	if v then
-- 		if type(v) == "function" then
-- 			v = v()
-- 		end
-- 		rawset(t, k, v)
-- 		return v
-- 	end
-- end

function ulf.init(opts)
	if ulf.initialized then
		return
	end
	ulf.process = require("ulf.core.process").global_process()
	init_logger(ulf)
	-- Seed Lua's RNG
	do
		math.randomseed(os.time())
	end
	ulf.logger.root.debug("ULF initialized")
	ulf.initialized = true
end

local function ensure_initilaized()
	if not ulf.initialized then
		ulf.init()
	end
end

local function package_setup(pack, name)
	-- call package setup if setup func is provided
	if type(pack.setup) == "function" then
		---TODO: user config
		local conf = pack.setup()
		P(conf.logging)
		register_logger(name, pack, conf.logging)
	end
end
ensure_initilaized()

return setmetatable(ulf, {
	__index = function(t, k)
		local pack = packages[k]
		ulf.logger.root.debug("ulf.__index: " .. tostring(k))

		if pack then
			if type(pack) == "function" then
				pack = pack()
			end
			package_setup(pack, k)
			rawset(t, k, pack)
			return pack
		end
	end,
})

---
-- return function(main, ...) ---@type fun(main:fun(...),...:any)
-- 	-- Inject the global process table
-- 	_G.process = require("ulf.core.process").global_process()
--
-- 	-- Seed Lua's RNG
-- 	do
-- 		math.randomseed(os.time())
-- 	end
--
-- 	local args = { ... }
-- 	local success, err = xpcall(function()
-- 		-- Call the main app inside a coroutine
-- 		local util = require("ulf.core.util")
--
-- 		local thread = coroutine.create(main)
-- 		util.assert_resume(thread, unpack(args))
--
-- 		-- Start the event loop
-- 		uv.run()
-- 	end, function(err)
-- 		-- During a stack overflow error, this can fail due to exhausting the remaining stack.
-- 		-- We can't recover from that failure, but wrapping it in a pcall allows us to still
-- 		-- return the stack overflow error even if the 'process.uncaughtException' fails to emit
-- 		pcall(function()
-- 			require("ulf.core.hooks"):emit("process.uncaughtException", err)
-- 		end)
-- 		return debug.traceback(err)
-- 	end)
--
-- 	if success then
-- 		-- Allow actions to run at process exit.
-- 		require("ulf.core.hooks"):emit("process.exit")
-- 		uv.run()
-- 	else
-- 		_G.process.exitCode = -1
-- 		require("ulf.util.pretty_print").stderr:write("Uncaught exception:\n" .. err .. "\n")
-- 	end
--
-- 	local function is_file_handle(handle, name, fd)
-- 		-- return _G.process[name].handle == handle and uv.guess_handle(fd) == "file"
-- 	end
-- 	local function is_stdio_file_handle(handle)
-- 		return is_file_handle(handle, "stdin", 0)
-- 			or is_file_handle(handle, "stdout", 1)
-- 			or is_file_handle(handle, "stderr", 2)
-- 	end
-- 	-- When the loop exits, close all unclosed uv handles (flushing any streams found).
-- 	uv.walk(function(handle)
-- 		if handle then
-- 			local function close()
-- 				if not handle:is_closing() then
-- 					handle:close()
-- 				end
-- 			end
-- 			-- The isStdioFileHandle check is a hacky way to avoid an abort when a stdio handle is a pipe to a file
-- 			-- TODO: Fix this in a better way, see https://github.com/luvit/luvit/issues/1094
-- 			if handle.shutdown and not is_stdio_file_handle(handle) then
-- 				handle:shutdown(close)
-- 			else
-- 				close()
-- 			end
-- 		end
-- 	end)
-- 	uv.run()
--
-- 	-- Send the exitCode to luvi to return from C's main.
-- 	return _G.process.exitCode
-- end
