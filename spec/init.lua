-- package.path = package.path .. ";" .. "/Users/al/config/nvim/lua/?.lua;" .. "/Users/al/config/nvim/lua/?/init.lua"
-- package.path = package.path .. ";" .. os.getenv("PWD") .. "/../?.lua;" .. os.getenv("PWD") .. "/../?/init.lua"
if vim then
	local Busted = require("corevim.core.busted")
	Busted.project_init()
end
