local Util = require("ulf.doc.util")
local function assign(key, value)
	return "--" .. key .. "=" .. "'" .. value .. "'"
end
require("ulf.util.debug")._G()

local uv = vim and vim.uv or require("luv")
describe("#ulf", function()
	describe("#ulf.doc.defaults", function()
		it("returns the default config", function()
			local Config = require("ulf.doc.config")

			local expect = {
				backends = {
					luacats = {
						description = "Parses LuaCATS annotations from any Lua file and generates customized output files",
						enabled = true,
						logging = {
							level = "debug",
						},
						plugin_path = "",
					},
					md_helptags = {
						description = "Injects code blocks into markdown (see LazyVim)",
						enabled = false,
						logging = {
							level = "debug",
						},
						plugin_path = "",
					},
					mini_doc = {
						description = "Generate Neovim help files",
						enabled = false,
						logging = {
							level = "debug",
						},
						plugin_path = "",
					},
					tree_sitter_lua = {
						description = "Uses tree-sitter-lua to parse LuaCATS annotations and generates a vimdoc.",
						enabled = true,
						logging = {
							level = "debug",
						},
						plugin_path = "",
					},
				},
				logging = {
					logger = {
						{
							enabled = true,
							icon = " ",
							name = "doc",
							writer = {
								fs = {
									level = "debug",
								},
								stdout = {
									level = "error",
								},
							},
						},
						{
							enabled = true,
							icon = " ",
							name = "gendocs",
							writer = {
								fs = {
									level = "debug",
								},
								stdout = {
									level = "error",
								},
							},
						},
					},
				},
			}
			-- assert.Table(Defaults)
			assert.same(expect, Config.defaults)
		end)
	end)
end)
