require("ulf.util.debug")._G()
describe("#ulf", function()
	it("reports no errors", function()
		local main_called = false
		local main = function()
			main_called = true
		end
		local ulf = require("ulf")(main)
		assert.True(main_called)
	end)
end)
