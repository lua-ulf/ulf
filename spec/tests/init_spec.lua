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
local busted = require("busted")

describe("#ulf #ulfboot module tests", function()
	local ulf = require("ulf")

	it("checks that ulf module is loaded and global", function()
		assert.is_not_nil(ulf)
		assert.are.equal(ulf, _G.ulf)
	end)

	it("checks that ulf is singleton", function()
		local ulf_2 = require("ulf")
		assert.is_not_nil(ulf_2)
		assert.are.equal(ulf_2, ulf)
		assert.are.equal(ulf_2, _G.ulf)
	end)

	it("checks the existence of P function", function()
		assert.are.equal("function", type(_G.P))
	end)

	it("checks the existence of ulf API and components", function()
		assert.is_not_nil(ulf.api)
		assert.is_not_nil(ulf.api.config)
		assert.is_not_nil(ulf.api.loader)
	end)

	local luv = require("luv")

	it("checks that luv module is loaded and has event loop", function()
		assert.is_not_nil(luv)
		assert.is_not_nil(luv._loop)
	end)

	local core = require("ulf.core")

	it("checks the existence of ulf.core and minilib", function()
		assert.is_not_nil(core)
		assert.is_not_nil(core.minilib)
	end)

	it("checks that ulf.core.mods.minilib is loaded", function()
		local minilib = require("ulf.core.mods.minilib")
		assert.is_not_nil(minilib)
	end)

	it("checks that ulf.doc and ulf.lib are loaded", function()
		local doc = require("ulf.doc")
		local lib = require("ulf.lib")
		assert.is_not_nil(doc)
		assert.is_not_nil(lib)
	end)

	it("checks that ulfboot.package is loaded", function()
		local Package = require("ulfboot.package")
		assert.Table(ulf._)
		assert.Table(ulf._.package)
		assert.Table(ulf._.package.loaded)
		assert.Table(ulf._.package.loaded["lib"])
	end)

	it("checks that ulf.util is loaded and in package.loaded", function()
		local util = ulf.util
		assert.is_not_nil(util)
		assert.is_not_nil(ulf._.package.loaded.util)
	end)
end)
