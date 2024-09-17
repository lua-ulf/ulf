require("ulf.util.debug")._G()
local main = function()
	print("main called")
end
local ulf = require("ulf")(main)
P({
	"debug ulf",
	ulf = ulf or "nil",
})
