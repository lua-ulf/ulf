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
local ffi = require("ffi")
require("ulf.util.debug")._G()

local path_sep = ffi.os == "Windows" and "\\" or "/"

---@param ... string
---@return string?
local function joinpath(...)
	return (table.concat({ ... }, path_sep):gsub(path_sep .. path_sep .. "+", path_sep))
end

---@return boolean
local function exists(file)
	return uv.fs_stat(file) ~= nil
end

---@return boolean
local function dir_exists(dir)
	local stat = uv.fs_stat(dir)
	if stat ~= nil and stat.type == "directory" then
		return true
	end
	return false
end

---@return {[string]:function}
local function packages_list()
	local packs = {}
	if exists(".gitignore") and dir_exists("deps") then
		local pack_dir = uv.fs_scandir("deps")

		while true do
			local name = uv.fs_scandir_next(pack_dir)
			if not name then
				break
			end
			local match = string.match(name, "^ulf%.(.*)$")
			if match then
				packs[match] = function()
					local p = joinpath("deps", name, "lua", "ulf", match, "init.lua")
					local v = loadfile(p)()
					return v
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

---comment
---@param key string
local function get(key) end

---@type ulf
local ulf = {} ---@diagnostic disable-line: missing-fields
_G.ulf = ulf

function ulf.init(opts)
	ulf.process = require("ulf.core.process").global_process()
	-- Seed Lua's RNG
	do
		math.randomseed(os.time())
	end
end

return setmetatable({}, {
	__index = function(t, k)
		local v = packages[k]

		P({
			"ULF init.__index",
			k = k,
		})
		if v then
			if type(v) == "function" then
				v = v()
			end
			rawset(t, k, v)
			return v
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
