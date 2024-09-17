require("ulf.util.debug")._G()

---@class test.ulf.Rectangle:ulf.ChildObject
---@field new fun(self:test.ulf.Rectangle,w:integer,h:integer):test.ulf.Rectangle
---@field get_area fun(...):integer
---@field w integer
---@field h integer

local instanceof = require("ulf.core.util").instanceof

local validator = {}

---comment
---@param got {}
---@param expect any
validator.Class = function(got, expect)
	---@type ulf.Object
	local class = got
	assert(class)
	assert.Table(class.meta)
	assert.Function(class.create)
	assert.Function(class.extend)
	assert.Function(class.new)
end

validator.Object = function(got, expect)
	---@type ulf.Object
	local object = got
	assert(object)
	assert.Table(object.meta)
	assert.Function(object.create)
	assert.Function(object.extend)
	assert.Function(object.new)
end

describe("#ulf.core", function()
	describe("#ulf.core.object.Object", function()
		local Object = require("ulf.core.object")
		it("provides an interface for creating and extending objects", function()
			validator.Class(Object)
		end)

		describe("create", function()
			it("creates a new instance of the root class", function()
				local obj = Object:create()
				validator.Object(Object)
			end)
		end)

		describe("extend", function()
			it("creates a child instance of the Object", function()
				local NoObj = {}
				local Rectangle = Object:extend()
				assert.True(instanceof(Rectangle, Object))
				assert.False(instanceof(NoObj, Object))
				assert.Table(Rectangle.meta)

				local meta = getmetatable(Rectangle)
				assert.Table(meta)

				local Square = Rectangle:extend()
				assert.True(instanceof(Square, Rectangle))
			end)
		end)

		describe("new", function()
			it("creates a new instance of Object and calls initialize if it exists", function()
				local Rectangle = Object:extend()

				---@cast Rectangle test.ulf.Rectangle
				function Rectangle:initialize(w, h)
					self.w = w
					self.h = h
				end
				function Rectangle:get_area()
					return self.w * self.h
				end
				local rect = Rectangle:new(3, 4)
				assert.equal(12, rect:get_area())
			end)
		end)
	end)
end)
