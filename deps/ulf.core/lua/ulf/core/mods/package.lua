---@brief [[
--- Module `ulf.core.package` provides utilities for managing Lua packages,
--- including handling metadata, caching, loading, and validation of packages.
--- The module supports operations such as registering, loading, and validating
--- packages and their associated modules.
---
--- The `Meta` class manages the metadata for each package, including details
--- such as the name, version, license, and dependencies.
---
--- The `Cache` class is used to cache loaded packages and provides methods
--- for registering and unregistering packages.
---
--- The `Package` class handles the core functionality for creating and
--- loading packages from file paths.
---
--- The following classes are exposed by this module:
--- - `Meta`: Manages package metadata
--- - `Cache`: Caches and manages registered packages
--- - `Package`: Main class for creating, loading, and validating packages
---
--- Testing
--- - use ulf.core_test to load the test module using the package module
---
--- Example:
---
--- <pre>
---
--- return {
---
--- 	package = {
--- 		meta = {
--- 			name = "ulf.core_test",
--- 			version = "0.1.0",
--- 			license = "Apache 2",
--- 			homepage = "http://github.com/lua-ulf/ulf.core",
--- 			description = "ulf.core contains core functionality for provides services for ulf packages",
--- 			tags = { "ulf", "meta", "neovim", "luajit" },
--- 			author = { name = "SHBorg" },
--- 			contributors = {
--- 				"SHBorg ",
--- 			},
--- 			dependencies = {},
--- 			files = {
--- 				"*.lua",
--- 				"!examples",
--- 				"!tests",
--- 				"!bench",
--- 				"!lit-*",
--- 			},
--- 		},
--- 		modules = {
---
--- 			cache = true,
--- 		},
--- 	},
--- }
---
--- local core_test = require("ulf.core_test")
---
--- -- cache module is loaded on the fly from mods
--- assert(core_test.cache)
--- </pre?
---
---@brief ]]---

---@class ulf.core.package
local M = {}

---@class ulf.core.package.Meta @Represents metadata for a package.
---@field name string The name of the package.
---@field version string The version of the package.
---@field description string The description of the package.
---@field license string The license of the package.
---@field homepage string The homepage URL of the package.
---@field tags string[] The tags associated with the package.
---@field author string The author of the package.
---@field contributors string[] The contributors to the package.
---@field dependencies string[] The dependencies of the package.
---@field files string[] The files related to the package.
local Meta = {}

---@type ulf.core.package.Meta
M.Meta = Meta

---@class ulf.core.package.PackageModuleConfig @Specification for a package module.
---@field name? string The optional name of the module.
---@field enabled boolean Whether the module is enabled.

---@alias ulf.core.package.PackageModuleSpec ulf.core.package.PackageModuleConfig|boolean

local minilib = require("ulf.core.mods.minilib")

---@class MetaSpec
M.MetaDefaults = {}

---comment
---@param spec MetaSpec
---@return ulf.core.package.Meta
function Meta.new(spec)
	local self = setmetatable({}, { __index = Meta })

	for key, value in
		pairs(spec --[[ @as table[] ]])
	do
		---@type any
		self[key] = value
	end
	return self
end

---@class ulf.core.package.Cache @Handles caching of registered packages.
---@field packages {[string]:any} A table storing cached packages.
local Cache = {
	packages = {},
}
setmetatable(Cache, {
	__index = function(t, k)
		local packages = rawget(t, "packages")
		if packages[k] then
			return packages[k]
		end
	end,
})
--- Registers a package into the cache.
---@param modpath string The module path.
---@param pack table The package to be registered.
function Cache.register(modpath, pack)
	if not Cache.packages[modpath] then
		Cache.packages[modpath] = pack
	end
end

--- Unregisters a package from the cache.
---@param modpath string The module path.
function Cache.unregister(modpath)
	if Cache.packages[modpath] then
		Cache.packages[modpath] = nil
	end
end

---@class ulf.core.package.PackageExportSpec @Describes the package specification.
---@field prefix string prefix path to modules
---@field modules? {[string]:ulf.PackageModule} Dictionary of modules the package provides

---@class ulf.core.package.PackageSpec @Describes the package specification.
---@field meta ulf.core.package.Meta Meta information of this package
---@field export? ulf.core.package.PackageExportSpec Export specification
M.PackageDefaults = {}

---@class ulf.core.package.Package @Represents a package with its metadata and modules.
---@field package ulf.core.package.PackageSpec @Package specifications
---@field path string The file path to the module
---@field modpath string The Lua module path (dotted)
---@field module any The endpoint of the actual module
local Package = {}

---@type ulf.core.package.Package
M.Package = Package

---@type ulf.core.package.PackageSpec

--- Creates a new `Package` instance
---@param modpath string path to index
---@param opts? {is_root:boolean,searchpath:fun(p:string,list:string[])?}
---@return ulf.core.package.Package
function Package.new(modpath, opts)
	opts = opts or {}
	local is_root = type(opts.is_root) == "boolean" and opts.is_root or false

	local self = setmetatable({}, { __index = Package })
	local searchpath = opts.searchpath or package.searchpath

	local path, msg = searchpath(modpath, package.path)
	if not path then
		local ppath = package.path:gsub(";", "\n")
		error(
			"Package.new: unable to find package path for '" .. tostring(modpath) .. "'\n" .. "package.path:\n" .. ppath
		)
	end

	self.path = path
	self.modpath = modpath
	if opts.package and opts.package.meta then
		self.meta = Meta.new(opts.package.meta)
	end

	return self
end

-- call package setup if setup func is provided
function Package:setup()
	if type(self.module.setup) == "function" then
		print("NOT IMPL")
	end
end

--- Validates a package structure to ensure it is properly formed
---@param modpath string
---@param module ulf.core.package.Package
function Package.validate(modpath, module)
	--- Validate if the name follows the "ulf.<any string>" format
	---@param k string
	---@param msg string
	---@return string
	local function err_text(k, msg)
		msg = msg or "%s must be a table"
		return string.format("[ulf.core.package.Package].validate: '%s' " .. msg, modpath, k)
	end

	assert(type(module) == "table", err_text("module"))
	assert(type(module.package) == "table", err_text("module.package"))
	assert(type(module.package.meta) == "table", err_text("module.package.meta"))
	if module.package.export then
		if module.package.export.prefix then
			assert(type(module.package.export.prefix) == "string", err_text("module.export.prefix"))
		end
		assert(type(module.package.export.modules) == "table", err_text("module.export.modules"))
	end
end

--- Finds the path of an ulf package
---@param modpath string The path to the module file.
---@return boolean @returns true if the modpath is the path of an ulf package
---@return string[]
function M.is_ulf_package(modpath)
	---list of lua module path elements
	---@type string[]
	local elem = minilib.split(modpath, "%.", { native = true })

	---TODO: handle error
	if not elem then
		return false
	end

	if #elem == 2 and elem[1] == "ulf" then
		return true, elem
	end
	return false, elem
end

--- Loads a package from a file and returns the package module.
---@param modpath string The path to the module file.
---@param is_root boolean Whether this is the root module.
---@param opts? {mode?: "b"|"t"|"bt", env?:table} Optional options for loading the file.
---@return ulf.core.package.Package? @The loaded package.
---@return string? @error text
function Package.load(modpath, is_root, opts)
	print(string.format("[ulf.core.package].Package.loadfile: %s", modpath))
	local pack = Package.new(modpath)
	local loader = loadfile(pack.path)

	if not loader then
		return nil, "Error loading package '" .. tostring(modpath) .. "'"
	end

	---@type ulf.core.package.Package
	local module = loader()
	if is_root then
		Package.validate(modpath, module)
		module = require("ulf.lib.module.lazy_exports_module")(module, module.package.export, modpath)
	else
		print(string.format("[ulf.core.package].Package.load: not a root module modpath=%s", modpath))
	end

	pack.module = module
	local name = modpath:match("ulf%.(%w+)%.*.*")
	Cache.register(name, pack)
	return pack.module
end

M.Cache = Cache
M.load = Package.load
M.new = Package.new
return M
