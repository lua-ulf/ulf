print("call_wrap")
vim.print(arg)

---@param files string
---@param output_file string
---@param debug? string
local function gendocs(files, output_file, debug)
	if type(debug) == "string" and debug == "nil" then
		debug = false ---@diagnostic disable-line: cast-local-type
	end
	print("[ulf.doc.gendocs.backend]: generating docs using vim/tree-sitter-lua")

	local Doc = require("ulf.doc.gendocs")
	local config = Doc.setup()
	require("ulf.doc.gendocs.loader").load(config)

	-- if debug then
	-- 	Debug.dump_lua_path("all")
	-- end

	---@type {write:fun(...)}
	local docgen = require("docgen")

	print(string.format("[ulf.doc.gendocs.backend]: files: %s", files))
	print(string.format("[ulf.doc.gendocs.backend]: output file: %s", output_file))
	local input_files = vim.split(files, ",", { plain = true })

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

gendocs(arg[1], arg[2], arg[3])
