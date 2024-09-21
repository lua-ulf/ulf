require("ulf.core.mods.debug")._G()
local minilib = require("ulf.core.mods.minilib")

local root = minilib.git_root()

local path_fixtures = minilib.joinpath(root, "deps", "ulf.core", "spec", "fixtures", "packages")
package.path = package.path .. ";" .. minilib.joinpath(path_fixtures, "ulf.core_test", "lua", "?.lua")
package.path = package.path .. ";" .. minilib.joinpath(path_fixtures, "ulf.core_test", "lua", "?", "init.lua")

local ulf_package = require("ulf.core.mods.package")

describe("#ulf.core", function()
	describe("ulf.core.package module", function()
		describe("Meta class", function()
			it("should create a Meta object with valid data", function()
				local spec = {
					name = "ulf.core_test",
					version = "0.1.0",
					license = "Apache 2",
					homepage = "http://github.com/lua-ulf/ulf.core",
					tags = { "ulf", "meta", "neovim", "luajit" },
					author = { name = "SHBorg" },
					contributors = { "SHBorg" },
					dependencies = {},
					files = { "*.lua", "!examples", "!tests" },
				}

				local meta = ulf_package.Meta.new(spec)

				assert.is_not_nil(meta)
				assert.are.equal(meta.name, "ulf.core_test")
				assert.are.equal(meta.version, "0.1.0")
				assert.are.same(meta.tags, { "ulf", "meta", "neovim", "luajit" })
				assert.are.same(meta.contributors, { "SHBorg" })
			end)
		end)
		describe("Cache class", function()
			it("should register a package in the cache", function()
				local package_data = { name = "ulf.core_test", version = "0.1.0" }
				ulf_package.Cache.register("ulf.core_test", package_data)

				local cached_package = ulf_package.Cache.packages["ulf.core_test"]
				assert.is_not_nil(cached_package)
				assert.are.equal(cached_package.name, "ulf.core_test")
				assert.are.equal(cached_package.version, "0.1.0")
			end)

			it("should unregister a package from the cache", function()
				ulf_package.Cache.unregister("ulf.core_test")

				local cached_package = ulf_package.Cache.packages["ulf.core_test"]
				assert.is_nil(cached_package)
			end)
		end)
		describe("Package class", function()
			it("should create a new Package object", function()
				local package_spec = {
					meta = {
						name = "ulf.core_test",
						version = "0.1.0",
					},
					modules = {
						cache = true,
					},
				}

				local package_obj = ulf_package.Package.new("ulf.core_test", { package = package_spec })

				assert.is_not_nil(package_obj)
				assert.are.equal(package_obj.modpath, "ulf.core_test")
				assert.is_not_nil(package_obj.meta)
				assert.are.equal(package_obj.meta.name, "ulf.core_test")
			end)

			it("should throw error if package path is not found", function()
				assert.has_error(function()
					ulf_package.Package.new("invalid.package")
				end)
			end)

			it("should validate a package structure", function()
				local valid_package = {
					package = {
						meta = {
							name = "ulf.core_test",
							version = "0.1.0",
						},
						modules = { cache = true },
					},
				}

				assert.has_no.errors(function()
					ulf_package.Package.validate("ulf.core_test", valid_package)
				end)
			end)

			it("should throw error on invalid package structure", function()
				local invalid_package = { package = {} }

				assert.has_error(function()
					ulf_package.Package.validate("ulf.core_test", invalid_package)
				end, "[ulf.core.package.Package].validate: 'ulf.core_test' module.package.meta must be a table")
			end)
		end)

		describe("Package.load function", function()
			it("should load a valid package", function()
				-- This test assumes that the package at modpath 'ulf.core_test' exists.
				local package_module, err = ulf_package.load("ulf.core_test", true)

				assert.is_not_nil(package_module)
				assert.is_nil(err)
			end)

			it("should return error if package load fails", function()
				---@type string
				local err
				local fails = function()
					_, err = pcall(ulf_package.load, "invalid.package", true)
					error(err)
				end
				assert.has_error(function()
					fails()
				end)

				local lines = minilib.split(err, "\n", { native = true })
				local err_msg = lines[1]:match("[%w%/]+:%d+:%s*(.*)")

				assert.equal("Package.new: unable to find package path for 'invalid.package'", err_msg)
			end)

			describe("Package.load returned module", function()
				it("should set a metatable to the module endpoint", function()
					-- This test assumes that the package at modpath 'ulf.core_test' exists.
					local package_module, err = ulf_package.load("ulf.core_test", true)

					local mt = getmetatable(package_module)
					assert.Table(package_module)
					assert.Table(mt)
				end)
				it("should provide access to the modules", function()
					-- This test assumes that the package at modpath 'ulf.core_test' exists.
					local package_module, err = ulf_package.load("ulf.core_test", true)
					assert.Table(package_module.cache)
					assert.Function(package_module.func)
					assert.Table(package_module.object)
					assert.equal("test.ulf.core.package.Object", package_module.object.name)
				end)
			end)
		end)
	end)
end)
