local ulf = require("ulf")
assert(ulf)
assert(ulf == _G.ulf)
local ulf_2 = require("ulf")
assert(ulf_2)
assert(ulf_2 == ulf)
assert(ulf_2 == _G.ulf)

assert(type(_G.P) == "function")
assert(ulf.api)
assert(ulf.api.config)
assert(ulf.api.loader)

local luv = require("luv")
assert(luv)
assert(luv._loop)

local core = require("ulf.core")
assert(core)
assert(core.minilib)

local minilib = require("ulf.core.mods.minilib")
assert(minilib)

local doc = require("ulf.doc")

local Package = require("ulf.core").package
-- P({
-- 	"ulf._.package.loaded",
-- 	ulf._.package.loaded["lib"],
-- })

local util = ulf.util
assert(util)
assert(ulf._.package.loaded.util)

local try1 = require("ulf.lib.func.try")
-- local func = ulf.lib.func
-- local func_lib = require("ulf.lib.func")
local try2 = ulf.lib.func.try
local catch = ulf.lib.func.catch
P({
	"AAAAAAAAAAAAAAAAAAA",
	-- func = func,
	try1 = try1,
	try2 = try2 or "nil",
	catch = catch,
})
