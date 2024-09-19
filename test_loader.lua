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
local lib = require("ulf.lib")

local Package = require("ulfboot.package")
P({
	"ulf._.package.loaded",
	ulf._.package.loaded["lib"],
})

local util = ulf.util
assert(util)
assert(ulf._.package.loaded.util)
