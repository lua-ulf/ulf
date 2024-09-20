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

	Package = require("ulf.core").package,
	Debug = require("ulf.core").debug,
	Inspect = require("ulf.core").inspect,
}
