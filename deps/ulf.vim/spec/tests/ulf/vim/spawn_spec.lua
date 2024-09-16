local stub = require("luassert.stub")
local mock = require("luassert.mock")
local uv = vim.uv

require("ulf.util.debug")._G()

describe("#ulf.vim.remote.spawn", function()
	describe("VimProcess", function()
		local VimProcess = require("ulf.vim.remote.spawn").VimProcess
		local SupportedVimTables = require("ulf.vim.remote.spawn").SupportedVimTables
		describe("call VimProcess", function()
			local proc = VimProcess()
			it("returns a new VimProcess instance", function()
				assert(proc)
			end)
			it("provides access to vim tables", function()
				for _, key in ipairs(SupportedVimTables) do
					assert(proc[key])
				end
			end)
			it("starts and stops a process", function()
				assert.has_no_error(function()
					proc:start()
					proc:stop()
				end)
			end)
		end)
	end)

	describe("VimProcess.uv", function()
		local VimProcess = require("ulf.vim.remote.spawn").VimProcess
		local proc = VimProcess()
		before_each(function()
			proc:start()
		end)
		after_each(function()
			proc:stop()
		end)
		describe("os_homedir", function()
			it("returns a the user's home dir", function()
				local got = proc.uv.os_homedir()
				assert.String(got)
			end)
		end)
	end)
end)
