---@class ulf.lib.path
local M = {}

local uv = vim and vim.uv or require("luv")

---@see folke/lazy.nvim/lua/lazy/core/util.lua
---
---@return string
function M.norm(path)
	if path:sub(1, 1) == "~" then
		local home = uv.os_homedir()
		-- failed, return unmodified
		if not home then
			return path
		end
		if home:sub(-1) == "\\" or home:sub(-1) == "/" then
			home = home:sub(1, -2)
		end
		path = home .. path:sub(2)
	end
	path = path:gsub("\\", "/"):gsub("/+", "/")
	return path:sub(-1) == "/" and path:sub(1, -2) or path
end

return M
