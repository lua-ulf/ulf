--[[

Copyright 2014 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]
local uv = vim and vim.uv or require("luv")
local unpack = unpack or table.unpack

---
return function(main, ...) ---@type fun(main:fun(...),...:any)
	-- Inject the global process table
	_G.process = require("ulf.core.process").global_process()

	-- Seed Lua's RNG
	do
		math.randomseed(os.time())
	end

	local args = { ... }
	local success, err = xpcall(function()
		-- Call the main app inside a coroutine
		local util = require("ulf.core.util")

		local thread = coroutine.create(main)
		util.assert_resume(thread, unpack(args))

		-- Start the event loop
		uv.run()
	end, function(err)
		-- During a stack overflow error, this can fail due to exhausting the remaining stack.
		-- We can't recover from that failure, but wrapping it in a pcall allows us to still
		-- return the stack overflow error even if the 'process.uncaughtException' fails to emit
		pcall(function()
			require("ulf.core.hooks"):emit("process.uncaughtException", err)
		end)
		return debug.traceback(err)
	end)

	if success then
		-- Allow actions to run at process exit.
		require("ulf.core.hooks"):emit("process.exit")
		uv.run()
	else
		_G.process.exitCode = -1
		require("ulf.util.pretty_print").stderr:write("Uncaught exception:\n" .. err .. "\n")
	end

	local function is_file_handle(handle, name, fd)
		-- return _G.process[name].handle == handle and uv.guess_handle(fd) == "file"
	end
	local function is_stdio_file_handle(handle)
		return is_file_handle(handle, "stdin", 0)
			or is_file_handle(handle, "stdout", 1)
			or is_file_handle(handle, "stderr", 2)
	end
	-- When the loop exits, close all unclosed uv handles (flushing any streams found).
	uv.walk(function(handle)
		if handle then
			local function close()
				if not handle:is_closing() then
					handle:close()
				end
			end
			-- The isStdioFileHandle check is a hacky way to avoid an abort when a stdio handle is a pipe to a file
			-- TODO: Fix this in a better way, see https://github.com/luvit/luvit/issues/1094
			if handle.shutdown and not is_stdio_file_handle(handle) then
				handle:shutdown(close)
			else
				close()
			end
		end
	end)
	uv.run()

	-- Send the exitCode to luvi to return from C's main.
	return _G.process.exitCode
end
