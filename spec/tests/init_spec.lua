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
	it("provides access to the core module using ulf.core", function()
		local ulf = require("ulf")
		local ulf_core = require("ulfboot.core")
		assert(ulf)

		local core = ulf.core
		assert(core)
	end)

	it("provides access to the doc module using ulf.doc", function()
		local ulf = require("ulf")
		assert(ulf)

		local doc = ulf.doc
		assert(doc)
	end)
	it("provides access to the log module using ulf.log", function()
		local ulf = require("ulf")
		assert(ulf)

		local log = ulf.log
		assert(log)
	end)
end)
