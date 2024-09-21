return {

	package = {
		meta = {
			name = "ulf.core_test",
			version = "0.1.0",
			license = "Apache 2",
			homepage = "http://github.com/lua-ulf/ulf.core",
			description = "ulf.core contains core functionality for provides services for ulf packages",
			tags = { "ulf", "meta", "neovim", "luajit" },
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
		},
		modules = {

			func = { enabled = true },
			object = { enabled = true },
			cache = true,
		},
	},
}
