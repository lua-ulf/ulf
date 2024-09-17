require("ulf.util.debug")._G()

local packages = {

	async = true,
	core = true,
	doc = true,
	lib = true,
	log = true,
	luvit = true,
	process = true,
	sys = true,
	test = true,
	util = true,
	vim = true,
}
describe("#ulf", function()
	it("provides access to modules", function()
		-- local main_called = false
		-- local main = function()
		-- 	main_called = true
		-- end
		local ulf = require("ulf")
		local got = {}
		for _, key in ipairs(packages) do
			local pack = ulf[key]
			P(pack)
			if pack then
				got[key] = true
			end
			-- assert(package)
			-- assert.Table(package)
			-- assert.same({ 1 }, package)
		end
		assert.same(got, packages)
		-- assert.True(main_called)
	end)
end)
