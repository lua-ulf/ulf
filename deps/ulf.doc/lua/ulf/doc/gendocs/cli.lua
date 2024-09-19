---@brief [[
--- ulf.doc.gendocs.cli is the command line interface for the gendocs module.
---
--- Example usage (see gendocs -h)
--- <pre>
---   gendocs --files="lua/ulf/doc/init.lua,lua/ulf/doc/gendocs/init.lua" --app="ulf.doc"
--- </pre>
---
---@brief ]]
---@tag ulf.doc.gendocs.cli
---@config { ["name"] = "Client" }
---
---@class ulf.doc.gendocs.cli.exports
local M = {}
local ModuleConfig = require("ulf.doc.config")
local minilib = require("ulf.core").minilib
local Config = require("ulf.doc.gendocs.config")
require("ulf.util.debug")._G()

local uv = vim and vim.uv or require("luv")

local cliargs_config = {

	tree_sitter_lua = {

		options = {
			{ key = "--app=APP", description = "Name of the app/plugin" },
			{
				key = "--loader_script=LOADER_SCRIPT",
				description = "The loader script which executes generation processs.",
			},
			{ key = "--files=FILES", description = "List of files " },
			{ key = "--config=CONFIG", description = "Path to config" },
			{ key = "--output_path=OUTPUT_PATH", description = "Path to output" },
			{ key = "--config=CONFIG", description = "Path to config" },
		},
	},
}
local create_cliarg = function()
	local spec = {
		name = "gendocs",
		description = "TODO no desc",
		commands = {},
	}

	for backend_name, backend in pairs(ModuleConfig.backends) do
		local command = cliargs_config[backend_name]
		if backend.enabled and command then
			spec.commands[#spec.commands + 1] = minilib.tbl_deep_extend("force", {
				name = backend.name,
				description = backend.description,
			}, command)
		end
	end
	local cli = require("ulf.core").argsutil.create_parser(spec)

	return cli
end
P(create_cliarg())
---@return boolean
local function exists(file)
	return uv.fs_stat(file) ~= nil
end

---@return boolean
local function dir_exists(dir)
	local stat = uv.fs_stat(dir)
	if stat ~= nil and stat.type == "directory" then
		return true
	end
	return false
end

-- this is called when the flag -v or --version is set
local function print_version()
	print("ulf.doc: version NOT-IMPLEMENTED")
	os.exit(0)
end

---comment
---@param cli table
---@param file_path? string
---@return ulf.doc.ConfigOptions?
function M.load_config_file(cli, file_path)
	local config = Config.load(file_path)

	if config and config.gendocs then
		cli:load_defaults(config.gendocs)
		return config
	end
end

---@class ulf.doc.gendocs.cliargs
---@field path_output? string
---@field files string
---@field app string
---@field d? boolean
---@field init_script? string
---@field config? string
---@field backend? 'vim'|'lua'
---
---@param args ulf.doc.gendocs.cliargs
local function main(args)
	require("ulf.doc.gendocs.backend").runner[args.backend].spawn(args)
end

local function init_script()
	local path = package.searchpath("ulf.doc.gendocs.vim_init", package.path)
	if not path then
		error("Cannot find script 'ulf.doc.gendocs.vim_init'")
	end
	return path
end

function M.run()
	local cli = require("cliargs") ---@diagnostic disable-line: no-unknown
	cli:set_name("gendocs")
	cli:set_description("generate Lua documentation")
	cli:option("--init_script=INIT_SCRIPT", "vim init script (defaults to 'ulf.doc.gendocs.vim_init')", init_script())
	cli:option("--app=APP", "name of the app")
	cli:option("--config=FILEPATH", "path to a config file")
	cli:option("--path_output=FILEPATH", "path to the generated documentation files", "doc")
	cli:option("--backend=BACKEND", "backend to use for generating docs: vim (default) or lua", "vim")
	cli:option("--files=FILES", "list of files to process")

	cli:flag("-d", "script will run in DEBUG mode")
	cli:flag("-v, --version", "prints the program's version and exits", print_version)
	-- M.load_config_file(cli, Config.filename())

	local args, err = cli:parse() ---@diagnostic disable-line: no-unknown

	-- something wrong happened, we print the error and exit
	if not args then
		print(string.format("%s: %s; re-run with help for usage", cli.name, err))
		os.exit(1)
	end
	if args.config and not exists(args.config) then
		args.config = nil
	else
		if exists(Config.filename()) then
			args.config = Config.filename()
		end
	end

	if not dir_exists(args.path_output) then
		print(string.format("path to output files does not exist: %s", args.path_output))
		os.exit(1)
	end
	-- finally, let's check if the user passed in a config file using --config:
	if args.config then
		---@type ulf.doc.ConfigOptions?
		local custom_config = M.load_config_file(cli, args.config)

		if custom_config then
			args.files = custom_config.gendocs.files or args.files
			args.app = custom_config.gendocs.app or args.app
		end
	end
	if args.files and args.app then
		main(args)
	else
		print(string.format("%s: files and app missing, run with help for usage", cli.name))
		os.exit(1)
	end
end

return M
