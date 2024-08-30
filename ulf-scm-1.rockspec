---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "loom"
version = "scm-1"
source = {
	url = "https://github.com/shborg-lua/loom/archive/refs/tags/scm-1.zip",
}

description = {
	summary = "Tool for managing Lua monorepos",
	detailed = "`loom` is a tool designed for managing and organizing Lua monorepos, built on top of LuaRocks.",
	homepage = "http://github.com/shborg-lua/loom",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1",
	"lua-cjson",
	"inspect",
	"lua_cliargs",
	"luafilesystem",
	"dkjson",
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
