---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "ulf"
version = "0.1.0-1"
source = {
	url = "https://github.com/shborg-lua/loom/archive/refs/tags/0.1.0-1.zip",
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
	-- "luvit",
	-- "cjson", -- have problems to install under luajit
	-- "dkjson",
	-- "tabular",
}
build = {
	type = "builtin",
	platforms = {},
	-- modules = {
	-- 	["ulf"] = "deps/ulf.core/lua/ulf/core",
	-- 	["ulf.doc"] = "deps/ulf.log/lua/ulf/doc",
	-- 	["ulf.log"] = "deps/ulf.log/lua/ulf/log",
	-- },
	-- install = {
	-- 	bin = {
	-- 		gendocs = "deps/ulf.doc/bin/gendocs",
	-- 	},
	-- },
	copy_directories = {
		"examples",
	},
}
test_dependencies = {
	"busted",
	"busted-htest",
	"nlua",
	"luafilesystem",
	"luacov",
	"luacov-html",
	"luacov-multiple",
	"luacov-console",
	"luafilesystem",
}
test = {
	type = "busted",
}
