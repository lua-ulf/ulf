-- This is for code that wants structured error messages.
---@class ulf.ErrorObject:ulf.ChildObject
---@field message string
local Error = require("ulf.core.object"):extend()

-- Make errors tostringable
---comment
---@param table ulf.ErrorObject
---@return string
function Error.meta.__tostring(table)
	return table.message
end

---comment
---@param message string
function Error:initialize(message)
	self.message = message
	if message then
		self.code = tonumber(message:match("([^:]+): "))
	end
end

return Error
