---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "ulf.util"
version = "0.1.0-1"
source = {
	url = "https://github.com/lua-ulf/ulf.async/archive/refs/tags/0.1.0-1.zip",
}

description = {
	summary = "ulf.util is a util module for the ULF framework.",
	detailed = "ulf.util is a util module for the ULF framework.",
	labels = { "docgen", "neovim", "ulf" },
	homepage = "http://github.com/lua-ulf/ulf.async",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1",
	"inspect",
}
build = {
	type = "builtin",
	modules = {},
	copy_directories = {},
	platforms = {},
}
test_dependencies = {
	"busted",
	"busted-htest",
	"luacov",
	"luacov-html",
	"luacov-multiple",
	"luacov-console",
	"luafilesystem",
}
test = {
	type = "busted",
}
