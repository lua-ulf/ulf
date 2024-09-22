---@class ulf.lib.trace
local M = {}

---@param opts? {level?: number, filter:fun(info:table?)}
---@return string
function M.pretty_trace(opts)
	opts = opts or {}
	local filter = opts.filter or function(info)
		return info.what ~= "C" and (info.source:find("ulf"))
	end

	local trace = {}
	local level = opts.level or 2
	while true do
		local info = debug.getinfo(level, "Sln")
		if not info then
			break
		end
		if filter(info) then
			local source = info.source:sub(2)
			-- source = vim.fn.fnamemodify(source, ":p:~:.") --[[@as string]]
			local line = "  - " .. source .. ":" .. info.currentline
			if info.name then
				line = line .. " _in_ **" .. info.name .. "**"
			end
			table.insert(trace, line)
		end
		level = level + 1
	end
	return #trace > 0 and ("\n\n# stacktrace:\n" .. table.concat(trace, "\n")) or ""
end

return M
