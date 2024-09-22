---@type ulf.PackageMeta
return {
	name = "ulf.lib",
	version = "0.1.0",
	license = "Apache 2",
	homepage = "http://github.com/lua-ulf/ulf.lib",
	description = "ulf.lib contains core functions and objects for the ulf project",
	tags = { "ulf", "neovim", "luajit" },
	author = { name = "SHBorg" },
	contributors = {
		"SHBorg ",
	},
	dependencies = {},
	files = {
		"*.lua",
		"!examples",
		"!tests",
		"!bench",
		"!lit-*",
	},
}
