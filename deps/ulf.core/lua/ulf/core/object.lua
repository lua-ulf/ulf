--[[
Copyright 2014 The Luvit Authors. All Rights Reserved.
--]]

---
--- This is the most basic object in Luvit. It provides simple prototypal
--- inheritance and inheritable constructors. All other objects inherit from this.
---
---@class ulf.Object
---@field initialize fun(...:any)
local Object = {}

---@class ulf.ObjectMeta
---@field __tostring? fun(t:ulf.ChildObject):string
---@field __index? ulf.Object
---@field super ulf.ChildObject
---@field meta? ulf.ObjectMeta
Object.meta = { __index = Object }

-- Create a new instance of this object
---comment
---@return ulf.Object
function Object:create()
	local meta = rawget(self, "meta")
	if not meta then
		error("Cannot inherit from instance object")
	end
	return setmetatable({}, meta)
end

--- Creates a new instance and calls `obj:initialize(...)` if it exists.
---
---     local Rectangle = Object:extend()
---     function Rectangle:initialize(w, h)
---       self.w = w
---       self.h = h
---     end
---     function Rectangle:getArea()
---       return self.w * self.h
---     end
---     local rect = Rectangle:new(3, 4)
---     p(rect:getArea())
---comment
---@param ... any
---@return ulf.Object
function Object:new(...)
	local obj = self:create()
	if type(obj.initialize) == "function" then
		obj:initialize(...)
	end
	return obj
end

---@class ulf.ChildObject:ulf.Object
---@field super ulf.Object
---@field meta ulf.ObjectMeta
---

--- Creates a new sub-class.
---
---     local Square = Rectangle:extend()
---     function Square:initialize(w)
---       self.w = w
---       self.h = h
---     end
---@return ulf.ChildObject
function Object:extend()
	local obj = self:create()
	---@type ulf.ObjectMeta
	local meta = {} ---@diagnostic disable-line: missing-fields
	-- move the meta methods defined in our ancestors meta into our own
	--to preserve expected behavior in children (like __tostring, __add, etc)
	for k, v in
		pairs(self.meta --[[@as function[] ]])
	do
		---@type function
		meta[k] = v
	end
	meta.__index = obj
	meta.super = self

	---@cast obj ulf.ChildObject
	obj.meta = meta
	return obj
end

return Object
