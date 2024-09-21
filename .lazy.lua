return {
	{ dir = "~/dev/projects/ulf/types", name = "ulf-types", lazy = true },
	{ dir = "~/dev/projects/ulf/deps/ulf.core", name = "ulf-core", lazy = true },
	{ dir = "~/dev/projects/ulf/deps/ulf.doc", name = "ulf-doc", lazy = true },
	{ dir = "~/dev/projects/ulf/deps/ulf.lib", name = "ulf-lib", lazy = true },
	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "ulf-lib", words = { "ulf%.lib" } },
				{ path = "ulf-doc", words = { "ulf%.doc" } },
				{ path = "ulf-core", words = { "ulf%.core" } },
				{ path = "ulf-types", words = { "ulf", "ulf%.core" } },
			},
		},
	},
}
