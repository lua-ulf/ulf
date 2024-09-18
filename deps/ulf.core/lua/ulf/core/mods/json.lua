---@brief [[
--- json contains a json wrapper
---
---@brief ]]

---@tag ulf.core.mods.json
---@config { ["name"] = "ULF.CORE.JSON" }
---

---@class ulf.core.json
---@field setup fun():ulf.core.json
local M = {}

---@class ulf.IJson
---@field encode fun(t:table,opts:table?)
---@field decode fun(s:string,opts:table?):table

---@alias ulf.core.json.mod_loader fun():ulf.IJson?

---@type {dkjson:ulf.core.json.mod_loader?,cjson:ulf.core.json.mod_loader?}
local loader = {}
---
loader.dkjson = function()
	---@type boolean
	local ok
	---@type table
	local json
	ok, json = pcall(require, "dkjson") ---@diagnostic disable-line: no-unknown
	if ok then
		return json
	end
end

-- loader.cjson = function()
-- 	---@type boolean
-- 	local ok
-- 	---@type table
-- 	local json
-- 	ok, json = pcall(require, "cjson") ---@diagnostic disable-line: no-unknown
-- 	print(ok, json)
-- 	if ok then
-- 		return json
-- 	end
-- end

---@type ulf.IJson?
local json

---comment
---@return ulf.core.json
function M.setup()
	if vim then
		return vim.json
	end

	for mod_name, load_fn in pairs(loader) do ---@diagnostic disable-line: no-unknown
		---@type ulf.IJson?
		local mod = load_fn()
		if mod then
			json = mod
			print("[ulf.doc.util.json]: using " .. mod_name .. " for json support")
			break
		end
	end
	return M
end

return setmetatable(M, {
	__index = function(t, k)
		if type(json) == "table" then
			---@type function
			local v = json[k]
			if type(v) == "function" then
				rawset(t, k, v)
				return v
			end
		end
	end,
})
