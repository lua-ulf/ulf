return {
	name = "lua-ulf/ulf.doc@0.1.0-2",
	version = "0.1.0",
	license = "Apache 2",
	homepage = "http://github.com/lua-ulf/ulf.doc",
	description = "ulf.doc provide tools for generating all kinds of documentation",
	tags = { "luv", "meta", "neovim", "luajit" },
	author = { name = "SHBorg" },
	contributors = {
		"SHBorg ",
	},
	dependencies = {
		"lua-ulf/ulf.core@0.1.0",
	},
	files = {
		"*.lua",
		"!examples",
		"!tests",
		"!bench",
		"!lit-*",
	},
}
