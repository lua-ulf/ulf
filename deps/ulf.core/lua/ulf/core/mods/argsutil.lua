---@brief [[
--- argsutil contains tools for working with command line arguments
---
---@brief ]]

---@tag ulf.core.mod.minilib
---@config { ["name"] = "ULF.CORE.ARGSUTIL" }
---

---
---@class ulf.core.argsutil
local argsutil = {}

---@alias ulf.core.argsutil.value_type string|fun(v:string):string

---@class ulf.core.argsutil.BaseArg
---@field name string Name of the argument
---@field key string Key name of the argument
---@field description string Help test for the argument
---@field callback string Callback to invoke when this argument is parsed.
---
---@class ulf.core.argsutil.ArgumentSpec : ulf.core.argsutil.BaseArg

---@class ulf.core.argsutil.OptionSpec : ulf.core.argsutil.BaseArg
---@field default boolean Default value for the option
---
---@class ulf.core.argsutil.FlagSpec : ulf.core.argsutil.BaseArg
---@field default boolean Default value for the flag
---
---@class ulf.core.argsutil.SplatSpec : ulf.core.argsutil.BaseArg
---@field maxcount integer The maximum number of occurences allowed.
---@field default any Default value for the splat

---@class ulf.core.argsutil.CommandSpec
---@field name string Name of the command
---@field description string Description of the cli
---@field arguments? ulf.core.argsutil.ArgumentSpec[]
---@field options? ulf.core.argsutil.OptionSpec[]
---@field flags? ulf.core.argsutil.FlagSpec[]
---@field splats? ulf.core.argsutil.SplatSpec[]
---
---
---
---@class ulf.core.argsutil.create_parser_opts : ulf.core.argsutil.BaseArg
---@field commands ulf.core.argsutil.CommandSpec[] commands for the cli
---
---@class ulf.core.argsutil.Parser
---@field on_config_data fun(data:table)
---

function argsutil.assert_spec(spec) end
---
---
---comment
---@param spec ulf.core.argsutil.create_parser_opts
---comment
function argsutil.create_parser(spec)
	argsutil.assert_spec(spec)

	---@return ulf.core.argsutil.Parser
	local function new_parser()
		cli = require("cliargs") ---@diagnostic disable-line: no-unknown
		cli:set_name(spec.name)
		cli:set_description(spec.description)
		for _, argument in ipairs(spec.arguments) do
			cli.argument(cli, argument.key, argument.description, argument.callback)
		end

		for _, option in ipairs(spec.options) do
			cli.option(cli, option.key, option.description, option.default, option.callback)
		end

		for _, flag in ipairs(spec.flag) do
			cli.option(cli, flag.key, flag.description, flag.default, flag.callback)
		end

		for _, splat in ipairs(spec.splats) do
			cli.argument(cli, splat.key, splat.description, splat.default, splat.maxcount, splat.callback)
		end

		for _, command in ipairs(spec.commands) do
			cli.command(cli, command.key, command.description)
		end
	end

	local cli = new_parser()

	---comment
	---@param cli table
	---@param file_path? string
	---@return unknown
	local function on_config_data(data)
		if data then
			cli:load_defaults(data)
		end
	end

	return {
		cli = cli,
		on_config_data = on_config_data,
	}
end

return argsutil
