---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "ulf.process"
version = "0.1.0-1"
source = {
	url = "https://github.com/lua-ulf/ulf.process/archive/refs/tags/0.1.0-1.zip",
}

description = {
	summary = "ulf.process provides functions and objects to work with processes.",
	detailed = "ulf.process provides functions and objects to work with processes.",
	labels = { "process", "neovim", "ulf" },
	homepage = "http://github.com/lua-ulf/ulf.process",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1",
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
	"nlua",
	"luacov",
	"luacov-html",
	"luacov-multiple",
	"luacov-console",
	"luafilesystem",
}
test = {
	type = "busted",
}
