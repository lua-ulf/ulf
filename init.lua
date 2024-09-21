---@type ulf.InitOptions
local config = {
	config = require("ulf.config"),
	---comment
	---@param ulf ulf
	---@param package ulf.core.package
	---@param config ulf.config
	get_loader = function(ulf, package, config)
		return require("ulf.loader").setup(ulf, package, config)
	end,

	package = require("ulf.core.mods.package"),
	debug = require("ulf.core.mods.debug"),
	inspect = require("ulf.core.mods.inspect"),
}
local ulf = require("ulf.main").init(config)
return ulf
