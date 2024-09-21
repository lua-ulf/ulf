---@meta _
---
---@class table<K, V>: { [K]: V }
---@class true: boolean
---@class false: boolean
---

---@class ulf.PackageMeta
local PackageMeta = {
	name = "lua-ulf/ulf.core@0.1.0-1",
	version = "0.1.0",
	license = "Apache 2",
	homepage = "",
	description = "",
	tags = { "ulf" },
	author = { name = "SHBorg" },
	contributors = {
		"SHBorg ",
	},
	dependencies = {},
	files = {
		"*.lua",
	},
}

---@class ulf.PackageModuleSpec
---@field name? string
---@field enabled boolean

---@alias ulf.PackageModule ulf.PackageModuleSpec|boolean

---@class ulf.PackageSpec
---@field meta ulf.PackageMeta
---@field modules? {[string]:ulf.PackageModule}
---
---

---@class ulf.Package
---@field package ulf.PackageSpec
