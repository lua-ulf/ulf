local Util = require("ulf.doc.util")
local function assign(key, value)
	return "--" .. key .. "=" .. "'" .. value .. "'"
end
require("ulf.util.debug")._G()

local uv = vim and vim.uv or require("luv")
describe("#ulf", function()
	describe("#ulf.doc.defaults", function()
		it("returns the default config", function()
			local Defaults = require("deps.ulf.doc.lua.ulf.doc.config")
			assert.Table(Defaults)
			assert.equal({}, Defaults)
		end)
	end)
end)
