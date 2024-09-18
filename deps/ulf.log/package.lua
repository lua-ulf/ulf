return {
	name = "lua-ulf/ulf.log@0.1.0-2",
	version = "0.1.0",
	license = "Apache 2",
	homepage = "http://github.com/lua-ulf/ulf.core",
	description = "ulf.log contains a logger for packages and external plugins",
	tags = { "lua", "ulf", "logger", "neovim" },
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
