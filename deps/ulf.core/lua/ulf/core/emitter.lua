--------------------------------------------------------------------------------

--- This class can be used directly whenever an event emitter is needed.
---
---     local emitter = Emitter:new()
---     emitter:on('foo', p)
---     emitter:emit('foo', 1, 2, 3)
---
--- Also it can easily be sub-classed.
---
---     local Custom = Emitter:extend()
---     local c = Custom:new()
---     c:on('bar', onBar)
---
--- Unlike EventEmitter in node.js, Emitter class doesn't auto binds `self`
--- reference. This means, if a callback handler is expecting a `self` reference,
--- utils.bind() should be used, and the callback handler should have a `self` at
--- the beginning its parameter list.
---
---     function some_func(self, a, b, c)
---     end
---     emitter:on('end', utils.bind(some_func, emitter))
---     emitter:emit('end', 'a', 'b', 'c')
---
---@alias ulf.bound_event_handler {callback:ulf.event_handler}
---@alias ulf.event_handler fun(name:string,...:any)
---@alias ulf.event_handler_map {[string]:ulf.event_handler|ulf.bound_event_handler}
---
---@class ulf.Emitter:ulf.ChildObject
---@field handlers ulf.event_handler_map
---@field super ulf.Object
---@field meta ulf.ObjectMeta
---@field on fun(self:ulf.Emitter,name:string,cb:fun(...))
---@field once fun(self:ulf.Emitter,name:string,cb:fun(...))
---@field listener_count fun(self:ulf.Emitter,name:string):integer
---@field missing_handler_type fun(self:ulf.Emitter,name:string,...:any)
---@field remove_listener fun(self:ulf.Emitter,name:string,callback:function)
---@field remove_all_listeners fun(self:ulf.Emitter)
---@field wrap fun(self:ulf.Emitter,name:string):ulf.event_handler
---@field propagate fun(self:ulf.Emitter,name:string,target:ulf.Emitter):ulf.Emitter
local Emitter = require("ulf.core.object"):extend()

-- By default, any error events that are not listened for should throw errors
function Emitter:missing_handler_type(name, ...)
	if name == "error" then
		--error(tostring(args[1]))
		-- we define catchall error handler
		if self ~= process then
			-- if process has an error handler
			local handlers = rawget(process, "handlers")
			if handlers and handlers["error"] then
				-- delegate to process error handler
				process:emit("error", ..., self)
			end
		end
	end
end

local once_meta = {}
function once_meta:__call(...)
	self.emitter:removeListener(self.name, self)
	return self.callback(...)
end

-- Same as `Emitter:on` except it de-registers itself after the first event.
function Emitter:once(name, callback)
	return self:on(
		name,
		setmetatable({
			emitter = self,
			name = name,
			callback = callback,
		}, once_meta)
	)
end

-- Adds an event listener (`callback`) for the named event `name`.
function Emitter:on(name, callback)
	local handlers = rawget(self, "handlers")
	if not handlers then
		handlers = {}
		rawset(self, "handlers", handlers)
	end
	local handlers_for_type = rawget(handlers, name)
	if not handlers_for_type then
		if self.addHandlerType then
			self:addHandlerType(name)
		end
		handlers_for_type = {}
		rawset(handlers, name, handlers_for_type)
	end
	table.insert(handlers_for_type, callback)
	return self
end

function Emitter:listener_count(name)
	local handlers = rawget(self, "handlers")
	if not handlers then
		return 0
	end
	local handlers_for_type = rawget(handlers, name)
	if not handlers_for_type then
		return 0
	else
		local count = 0
		for i = 1, #handlers_for_type do
			if handlers_for_type[i] then
				count = count + 1
			end
		end
		return count
	end
end

-- Emit a named event to all listeners with optional data argument(s).
function Emitter:emit(name, ...)
	local handlers = rawget(self, "handlers")
	if not handlers then
		self:missing_handler_type(name, ...)
		return
	end
	local handlers_for_type = rawget(handlers, name)
	if not handlers_for_type then
		self:missing_handler_type(name, ...)
		return
	end
	for i = 1, #handlers_for_type do
		local handler = handlers_for_type[i]
		if handler then
			handler(...)
		end
	end
	for i = #handlers_for_type, 1, -1 do
		if not handlers_for_type[i] then
			table.remove(handlers_for_type, i)
		end
	end
	return self
end

-- Remove a listener so that it no longer catches events.
-- Returns the number of listeners removed, or nil if none were removed
function Emitter:remove_listener(name, callback)
	local num_removed = 0

	local handlers = rawget(self, "handlers")
	if not handlers then
		return
	end
	local handlers_for_type = rawget(handlers, name)
	if not handlers_for_type then
		return
	end
	if callback then
		for i = #handlers_for_type, 1, -1 do
			local h = handlers_for_type[i]
			if type(h) == "function" then
				h = h == callback
			elseif type(h) == "table" then
				h = h == callback or h.callback == callback
			end
			if h then
				handlers_for_type[i] = false
				num_removed = num_removed + 1
			end
		end
	else
		for i = #handlers_for_type, 1, -1 do
			handlers_for_type[i] = false
			num_removed = num_removed + 1
		end
	end
	return num_removed > 0 and num_removed or nil
end

-- Remove all listeners
--  @param {String?} name optional event name
function Emitter:remove_all_listeners(name)
	local handlers = rawget(self, "handlers")
	if not handlers then
		return
	end
	if name then
		local handlers_for_type = rawget(handlers, name)
		if handlers_for_type then
			for i = #handlers_for_type, 1, -1 do
				handlers_for_type[i] = false
			end
		end
	else
		rawset(self, "handlers", {})
	end
end

-- Get listeners
--  @param {String} name event name
function Emitter:listeners(name)
	local handlers = rawget(self, "handlers")
	return handlers and (rawget(handlers, name) or {}) or {}
end

--[[
Utility that binds the named method `self[name]` for use as a callback.  The
first argument (`err`) is re-routed to the "error" event instead.

    local Joystick = Emitter:extend()
    function Joystick:initialize(device)
      self:wrap("onOpen")
      FS.open(device, self.onOpen)
    end

    function Joystick:onOpen(fd)
      -- and so forth
    end
]]
function Emitter:wrap(name)
	local fn = self[name]
	self[name] = function(err, ...)
		if err then
			return self:emit("error", err)
		end
		return fn(self, ...)
	end
end

-- Propagate the event to another emitter.
function Emitter:propagate(event_name, target)
	if target and target.emit then
		self:on(event_name, function(...)
			target:emit(event_name, ...)
		end)
		return target
	end

	return self
end

---@type ulf.Emitter
return Emitter
