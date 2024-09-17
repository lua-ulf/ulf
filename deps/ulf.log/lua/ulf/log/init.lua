---@type ulf.log
return {

	package = {
		name = "lua-ulf/ulf.log@0.1.0",
		version = "0.1.0",
	},
	severity = require("ulf.log.severity"),
	-- get = require("ulf.log.manager").get,
	-- register = require("ulf.log.client.register").register,
	register = require("ulf.log.loader").register,
}
