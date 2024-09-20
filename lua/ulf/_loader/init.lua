---@class ulf.Loader
return {
	Config = require("ulf._loader.config"),
	---comment
	---@param ulf ulf
	---@param package ulf._loader.package
	---@param config ulf.config
	get_loader = function(ulf, package, config)
		return require("ulf._loader.loader").setup(ulf, package, config)
	end,

	Package = require("ulf._loader.package"),
	Debug = require("ulf._loader.debug"),
	Inspect = require("ulf._loader.inspect"),
}
