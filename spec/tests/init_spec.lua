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

local validator = {}

---comment
---@generic T
---@param got ulf
---@param expect {[string]:any}
validator.package = function(got, expect)
	assert.is_not_nil(got)
	local module = got[expect.module_name]
	assert.Table(module)

	for mod_name, validate_spec in pairs(expect.is_module) do
		local child_module = module[mod_name]
		it("returns the module ulf." .. expect.module_name, function()
			assert.Table(child_module)
		end)
		for _, v in ipairs(validate_spec) do
			it("ulf." .. expect.module_name .. "." .. v.name .. " is a " .. v.type, function()
				v.assert(child_module)
			end)
		end
	end
end

---comment
---@generic T
---@param got ulf
---@param expect {[string]:any}
validator.package_module = function(got, expect)
	assert.is_not_nil(got)
	local modpath = expect.root .. "." .. expect.module_name
	local module = got[expect.module_name]

	it(expect.root .. " has " .. modpath, function()
		assert.Table(module)
	end)

	it(modpath .. " has a metatable", function()
		local mt = getmetatable(module)
		assert.Table(mt)
		assert.equal(modpath, mt.__name)
	end)

	local err_text_entry = function(entry_path, entry_spec)
		return string.format("expect '%s' to be a '%s'", entry_path, entry_spec.kind)
	end
	for entry_name, entry_spec in pairs(expect.entries) do
		local entry_path = modpath .. "." .. entry_name
		local v = module[entry_name]
		P(v, module)
		it(entry_path .. " is a " .. entry_spec.kind, function()
			assert(v)
			assert[entry_spec.kind](v, err_text_entry(entry_path, entry_spec))
		end)
	end
end

local V = {}
V.has_function = function(key)
	return {
		assert = function(module)
			assert.Function(module[key])
		end,
		type = "function",
		name = key,
	}
end

describe("#ulf module tests", function()
	local ulf = require("ulf")

	describe("ulf instance", function()
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
	end)

	describe("globals", function()
		it("checks the existence of P function", function()
			assert.are.equal("function", type(_G.P))
		end)
	end)
	describe("ulf", function()
		describe("#ulf.lib", function()
			describe("types", function()
				validator.package_module(ulf.lib, {
					root = "ulf.lib",
					module_name = "types",

					entries = {
						is_callable = { kind = "function" },
					},
				})
			end)
			describe("func", function()
				validator.package_module(ulf.lib, {
					root = "ulf.lib",
					module_name = "func",
					entries = {
						try = { kind = "function" },
					},
				})
			end)
			describe("table", function()
				validator.package_module(ulf.lib, {
					root = "ulf.lib",
					module_name = "table",
					entries = {
						validate = { kind = "function" },
						spairs = { kind = "function" },
					},
				})
			end)
			describe("module", function()
				validator.package_module(ulf.lib, {
					root = "ulf.lib",
					module_name = "module",
					entries = {
						lazy_exports_module = { kind = "function" },
						lazy_module = { kind = "function" },
					},
				})
			end)
			describe("module", function()
				validator.package_module(ulf.lib, {
					root = "ulf.lib",
					module_name = "string",
					entries = {
						split = { kind = "function" },
					},
				})
			end)
		end)
		describe("core", function()
			validator.package(ulf, {

				module_name = "core",
				is_module = {

					debug = { V.has_function("debug_print") },
				},
			})
		end)
		describe("accessing ulf.lib", function()
			validator.package(ulf, {

				module_name = "lib",
				is_module = {

					table = { V.has_function("spairs") },
					func = { V.has_function("try") },
				},
			})
		end)
	end)

	describe("access to API", function()
		it("checks the existence of ulf API and components", function()
			assert.is_not_nil(ulf.api)
			assert.is_not_nil(ulf.api.config)
			assert.is_not_nil(ulf.api.loader)
		end)
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
		local Package = require("ulf.core").package
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
