---@class apipe.lib.call
local M = {}

local pretty_trace = require("ulf.lib.trace").pretty_trace

---@generic R
---@param fn fun():R?
---@param opts? string|{msg:string, on_error:fun(msg)}
---@return R
function M.try(fn, opts)
	opts = type(opts) == "string" and { msg = opts } or opts or {}
	local msg = opts.msg

	-- error handler
	---@param err string
	---@return string
	local error_handler = function(err)
		msg = (msg and (msg .. "\n\n") or "") .. err .. pretty_trace()
		if opts.on_error then
			opts.on_error(msg)
		else
			---TODO: async error handling
			-- vim.schedule(function()
			-- 	M.error(msg)
			-- end)
		end
		return err
	end

	---@type boolean, any
	local ok, result = xpcall(fn, error_handler)
	return ok and result or nil
end
return M
