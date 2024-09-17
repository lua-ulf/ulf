require("ulf.util.debug")._G()

local instanceof = require("ulf.core.util").instanceof

local validator = {}

---comment
---@param got {}
---@param expect any
validator.Emitter = function(got, expect)
	---@type ulf.Emitter
	local emitter = got
end

describe("#ulf.core", function()
	describe("#ulf.core.emitter", function()
		local Emitter = require("ulf.core.emitter")

		describe("provides on and emit", function()
			it("creates a new instance of the root class", function()
				local emitter = Emitter:new()

				local got_data = {}
				function handler(...)
					got_data = { ... }
				end
				emitter:on("foo", handler)
				emitter:emit("foo", 1, 2, 3)
			end)
		end)
	end)
end)
