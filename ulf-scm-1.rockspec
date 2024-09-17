---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "ulf"
version = "scm-1"
source = {
	url = "https://github.com/shborg-lua/loom/archive/refs/tags/scm-1.zip",
}

description = {
	summary = "ULF is a library for Lua, LuaJIT, and Neovim, providing modules common development tasks.",
	homepage = "http://github.com/lua-ulf/ulf",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1",
	"luv",
	"inspect",
	"luafilesystem",
	-- "cjson", -- have problems to install under luajit
	"dkjson",
	"tabular",
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
