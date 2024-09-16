return {
	name = "lua-ulf/ulf",
	version = "0.1.0",
	license = "Apache 2",
	homepage = "https://github.com/luvit/luvit",
	description = "ULF is a modular framework for Lua designed to provide developers with an intuitive API for development in Neovim and Luajit.",
	tags = { "luv", "meta", "neovim", "luajit" },
	author = { name = "SHBorg" },
	contributors = {
		"SHBorg ",
	},
	dependencies = {
		"lua-ulf/ulf.lib@0.1.0",
	},
	files = {
		"*.lua",
		"!examples",
		"!tests",
		"!bench",
		"!lit-*",
	},
}
