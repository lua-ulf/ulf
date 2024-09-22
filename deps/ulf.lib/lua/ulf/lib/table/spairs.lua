---@tag ulf.lib.table.spairs

---@source neovim/runtime/lua/vim/shared.lua#spairs
--- Enumerates key-value pairs of a table, ordered by key.
---
---@see Based on https://github.com/premake/premake-core/blob/master/src/base/table.lua
---@see vim.spairs
---
---@generic T: table, K, V
---@param t T Dict-like table
---@return fun(table: table<K, V>, index?: K):K, V # |for-in| iterator over sorted keys and their values
---@return T
local function spairs(t)
	assert(type(t) == "table", "[ulf.lib.table].spairs: t must be a table")
	--- @cast t table<any,any>

	-- collect the keys
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	table.sort(keys)

	-- Return the iterator function.
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end, t
end

return spairs
