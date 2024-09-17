---@class ulf.doc.gendocs.backend.exports
local M = {}
local fs = require("ulf.doc.util.fs")
local Util = require("ulf.doc.util")
local Config = require("ulf.doc.gendocs.config")
local core = require("ulf.doc.util.core")
local _string = require("ulf.doc.util.string")
local gsplit = _string.gsplit
local split = _string.split
local Debug = require("ulf.doc.util.debug")

---@class ulf.doc.gendocs.backend.runner
local runner = {
	vim = {},
}

local function print_package_path()
	for value in gsplit(package.path, ";", { plain = true }) do
		print(value)
	end
end

---@param files string
---@param output_file string
---@param debug? string
function runner.vim.callback(files, output_file, debug)
	if type(debug) == "string" and debug == "nil" then
		debug = false ---@diagnostic disable-line: cast-local-type
	end
	print("[ulf.doc.gendocs.backend]: generating docs using vim/tree-sitter-lua")

	local Doc = require("ulf.doc.gendocs")
	local config = Doc.setup()
	require("ulf.doc.gendocs.loader").load(config)

	if debug then
		Debug.dump_lua_path("all")
	end

	---@type {write:fun(...)}
	local docgen = require("docgen")

	print(string.format("[ulf.doc.gendocs.backend]: files: %s", files))
	print(string.format("[ulf.doc.gendocs.backend]: output file: %s", output_file))
	local input_files = split(files, ",", { plain = true })

	local output_file_handle = io.open(output_file, "w")
	if not output_file_handle then
		error("error opening output file")
	end

	for _, input_file in ipairs(input_files) do
		docgen.write(input_file, output_file_handle)
	end

	output_file_handle:write(" vim:tw=78:ts=8:ft=help:norl:\n")
	output_file_handle:close()
	vim.cmd([[checktime]])
end

---comment
---@param s string
---@param k? string
---@return string
local q = function(s, k)
	k = k or "'"
	return k .. s .. k
end

local VimArgs = {}
VimArgs.rtp = function()
	local rtp_path_cmd = ""
	for _, value in ipairs(Config.runtime_paths()) do
		rtp_path_cmd = rtp_path_cmd .. 'vim.opt.rtp:append("' .. value .. '");'
	end
	return rtp_path_cmd
end

---@param files string
---@param output_file string
---@param debug_flag? boolean
VimArgs.runner_callback = function(files, output_file, debug_flag)
	local d_flag = (type(debug_flag) == "boolean" and (debug_flag and "true" or "false")) or "false"

	local start = "autocmd VimEnter,BufEnter * ++nested lua vim.print('ENTER'); require("
		.. q("ulf.doc.gendocs.backend")
		.. ").runner.vim.callback("
	local ending = [[)]]

	local args_list = {}
	args_list[#args_list + 1] = q(files)
	args_list[#args_list + 1] = q(output_file)
	args_list[#args_list + 1] = q(d_flag)

	return start .. table.concat(args_list, ",") .. ending
end

local function call_script()
	local path = package.searchpath("ulf.doc.gendocs.call_wrap", package.path)
	if not path then
		error("Cannot find script 'ulf.doc.gendocs.call_wrap'")
	end
	return path
end
VimArgs.runner_callback_debug = function(files, output_file, debug_flag)
	-- local start = "autocmd VimEnter,BufEnter * ++nested lua vim.print('ENTER')"
	-- return start
	local d_flag = (type(debug_flag) == "boolean" and (debug_flag and "true" or "false")) or "false"

	args_list = {}
	args_list[#args_list + 1] = call_script()
	args_list[#args_list + 1] = q(files)
	args_list[#args_list + 1] = q(output_file)
	args_list[#args_list + 1] = q(d_flag)

	return table.concat(args_list, ",")
end

---@param args ulf.doc.cliargs
function runner.vim.spawn(args)
	-- P(args)
	local output_file = fs.joinpath(args.path_output, args.app .. ".txt")
	Config.setup()
	-- FIXME: I'm trying to load the plugins without an init file
	-- fails with:
	-- E5108: Error executing lua ...l/.local/share/nvim/runtime/lua/vim/treesitter/query.lua:252: Query error at 1:2. Invalid node type "module_return_st
	-- atement":
	-- (module_return_statement (identifier) @exported)
	--
	-- I know there is some func to load a treesitter module manually. Maby this helps.
	-- currently no time to fix this
	--
	--
	-- add runtime paths: se problem above
	local cmd_args = {
		-- "nvim",
		"--headless",
		"-u",
		args.init_script,
		-- "-c",
		-- q(VimArgs.runner_callback_debug(args.files, output_file, args.d), [["]]),
		-- "-cq",
		"-l",
		call_script(),
		args.files,
		output_file,
		"false",
	}

	-- local result = Util.core.run_command("/Users/al/dev/projects/ulf/deps/ulf.doc/lua/ulf/doc/gendocs/wrap.sh", cmd_args)
	local result = Util.core.run_command("nvim", cmd_args)
	print(result)

	-- local runner_callback_args = VimArgs.runner_callback(args.files, output_file, args.d)
	-- print(table.concat(cmd_args, " "))
end

M.runner = runner
return M
