local stub = require("luassert.stub")
local mock = require("luassert.mock")
local uv = mock(vim and vim.uv or require("luv"), true)

describe("#ulf.lib", function()
	describe("#ulf.lib.path", function()
		local orig = {
			uv = {},
		}
		before_each(function()
			uv.os_homedir.returns("/home/test")
		end)
		local Path = require("ulf.lib.path")
		describe("norm", function()
			it("returns a normalized path", function()
				local p = "~/dev"
				local got = Path.norm(p)
				assert(got)
				assert.String(got)
				assert.equal("/home/test/dev", got)
			end)
		end)
	end)
end)
