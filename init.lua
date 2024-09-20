-- local Core = require("ulfboot")
-- return Core
-- require("ulf._loader.debug")._G()

local loader = require("ulf._loader")

local ulf = require("ulf.main").init({
	loader = require("ulf._loader"),
})
return ulf
-- P(1)

-- local Core = require("ulf.core.loader")
-- return Core
