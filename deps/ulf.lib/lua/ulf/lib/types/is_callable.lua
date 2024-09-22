---@tag ulf.lib.types.is_callable

---@source neovim/runtime/lua/vim/shared.lua#is_callable
---
--- Returns true if object `f` can be called as a function.
---
---@param f any Any object
---@return boolean `true` if `f` is callable, else `false`
local function is_callable(f)
	if type(f) == "function" then
		return true
	end
	local m = getmetatable(f)
	if m == nil then
		return false
	end
	return type(rawget(m, "__call")) == "function"
end

return is_callable
