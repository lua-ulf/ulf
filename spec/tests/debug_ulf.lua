require("ulf").util.debug._G()
local ulf = require("ulf")
P({
	"debug ulf",
	ulf = ulf or "nil",
})
local packages = {

	async = true,
	core = true,
	doc = true,
	lib = true,
	log = true,
	luvit = true,
	process = true,
	sys = true,
	test = true,
	util = true,
	vim = true,
}

local Core = ulf.core
P({
	"Core!!!!!!!!1",
	Core,
})

local minilib = Core.minilib
P(minilib)
for _, key in ipairs(packages) do
	local package = ulf[key]
	if package then
		P(package)
	end
end
