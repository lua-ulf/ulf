---@class ulf.core.util
local util = {}

local unpack = unpack or table.unpack ---@diagnostic disable-line: deprecated
local Error = require("ulf.core.error")

local pp = require("ulf.util.pretty_print")
for name, value in pairs(pp) do
	util[name] = value
end

---comment
---@param thread thread
---@param ... any
function util.assert_resume(thread, ...)
	local success, err = coroutine.resume(thread, ...)
	if not success then
		error(debug.traceback(thread, err), 0)
	end
end

---comment
---@param fn function
---@param self any
---@param ... any
---@return function
function util.bind(fn, self, ...)
	assert(fn, "fn is nil")
	local bind_args_length = select("#", ...)

	-- Simple binding, just inserts self (or one arg or any kind)
	if bind_args_length == 0 then
		return function(...)
			return fn(self, ...)
		end
	end

	-- More complex binding inserts arbitrary number of args into call.
	local bind_args = { ... }
	return function(...)
		local args_length = select("#", ...)
		local args = { ... }
		local arguments = {}
		for i = 1, bind_args_length do
			---@type any
			arguments[i] = bind_args[i]
		end
		for i = 1, args_length do
			---@type any
			arguments[i + bind_args_length] = args[i]
		end
		return fn(self, unpack(arguments, 1, bind_args_length + args_length))
	end
end

---comment
---@param err any
function util.noop(err)
	if err then
		print("Unhandled callback error", err)
	end
end

---j
---@param c any
---@param fn function
---@param ... any
---@return unknown
---@return unknown
function util.adapt(c, fn, ...)
	local nargs = select("#", ...)
	local args = { ... }
	-- No continuation defaults to noop callback
	if not c then
		c = noop
	end
	local t = type(c)
	if t == "function" then
		args[nargs + 1] = c
		return fn(unpack(args))
	elseif t ~= "thread" then
		error("Illegal continuation type " .. t)
	end
	local err, data, waiting
	args[nargs + 1] = function(e, ...)
		if waiting then
			if e then
				assert_resume(c, nil, e)
			else
				assert_resume(c, ...)
			end
		else
			err, data = e and Error:new(e), { ... }
			c = nil
		end
	end
	fn(unpack(args))
	if c then
		waiting = true
		return coroutine.yield()
	elseif err then
		return nil, err
	else
		return unpack(data)
	end
end

--- Returns whether obj is instance of class or not.
---
---     local object = Object:new()
---     local emitter = Emitter:new()
---
---     assert(instanceof(object, Object))
---     assert(not instanceof(object, Emitter))
---
---     assert(instanceof(emitter, Object))
---     assert(instanceof(emitter, Emitter))
---
---     assert(not instanceof(2, Object))
---     assert(not instanceof('a', Object))
---     assert(not instanceof({}, Object))
---     assert(not instanceof(function() end, Object))
---
--- Caveats: This function returns true for classes.
---     assert(instanceof(Object, Object))
---     assert(instanceof(Emitter, Object))
---
---@param obj ulf.ChildObject
---@param class ulf.ChildObject
---@return boolean
function util.instanceof(obj, class)
	if type(obj) ~= "table" or obj.meta == nil or not class then
		return false
	end
	if obj.meta.__index == class then
		return true
	end
	local meta = obj.meta
	while meta do
		if meta.super == class then
			return true
		elseif meta.super == nil then
			return false
		end
		meta = meta.super.meta
	end
	return false
end

return util
