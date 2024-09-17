--[[

Copyright 2014-2015 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]
--[[lit-meta
  name = "luvit/timer"
  version = "2.0.2"
  dependencies = {
    "luvit/core@2.0.0",
    "luvit/utils@2.1.0",
  }
  license = "Apache 2"
  homepage = "https://github.com/luvit/luvit/blob/master/deps/timer.lua"
  description = "Javascript style setTimeout and setInterval for luvit"
  tags = {"luvit", "timer"}
]]
---@type uv
local uv = vim and vim.uv or require("luv")

local Object = require("ulf.core.object")
local bind = require("ulf.core.util").bind
local assert_resume = require("ulf.core.util").assert_resume
local unpack = unpack or table.unpack

-------------------------------------------------------------------------------

---@class ulf.Timer:ulf.ChildObject
---@field private _active boolean
---@field private _handle uv_timer_t
local Timer = Object:extend()

function Timer:initialize()
	self._handle = uv.new_timer()
	self._active = false
end

function Timer:_update()
	self._active = uv.is_active(self._handle)
end

-- Timer:start(timeout, interval, callback)
function Timer:start(timeout, interval, callback)
	uv.timer_start(self._handle, timeout, interval, callback)
	self:_update()
end

-- Timer:stop()
function Timer:stop()
	uv.timer_stop(self._handle)
	self:_update()
end

-- Timer:again()
function Timer:again()
	uv.timer_again(self._handle)
	self:_update()
end

-- Timer:close()
function Timer:close()
	uv.close(self._handle)
	self:_update()
end

-- Timer:setRepeat(interval)
Timer.setRepeat = uv.timer_set_repeat

-- Timer:getRepeat()
Timer.getRepeat = uv.timer_get_repeat

-- Timer.now
Timer.now = uv.now

------------------------------------------------------------------------------

---comment
---@async
---@param delay integer
---@param thread thread
---@return thread
local function sleep(delay, thread)
	thread = thread or coroutine.running()
	local timer = uv.new_timer()
	uv.timer_start(timer, delay, 0, function()
		uv.timer_stop(timer)
		uv.close(timer)
		return assert_resume(thread)
	end)
	return coroutine.yield()
end

---comment
---@param delay integer
---@param callback function
---@param ... any
---@return uv_timer_t
local function set_timeout(delay, callback, ...)
	local timer = uv.new_timer()
	local args = { ... }
	uv.timer_start(timer, delay, 0, function()
		uv.timer_stop(timer)
		uv.close(timer)
		callback(unpack(args))
	end)
	return timer
end

---comment
---@param interval integer
---@param callback function
---@param ... any
---@return uv_timer_t
local function set_interval(interval, callback, ...)
	local timer = uv.new_timer()
	uv.timer_start(timer, interval, interval, bind(callback, ...))
	return timer
end

---comment
---@param timer uv_timer_t
local function clear_interval(timer)
	if uv.is_closing(timer) then
		return
	end
	uv.timer_stop(timer)
	uv.close(timer)
end

---@type uv_check_t
local checker = uv.new_check()
---@type uv_idle_t
local idler = uv.new_idle()

local immediate_queue = {}

local function on_check()
	local queue = immediate_queue
	immediate_queue = {}
	for i = 1, #queue do
		queue[i]()
	end
	-- If the queue is still empty, we processed them all
	-- Turn the check hooks back off.
	if #immediate_queue == 0 then
		uv.check_stop(checker)
		uv.idle_stop(idler)
	end
end

---comment
---@param callback function
---@param ... any
local function set_immediate(callback, ...)
	-- If the queue was empty, the check hooks were disabled.
	-- Turn them back on.
	if #immediate_queue == 0 then
		uv.check_start(checker, on_check)
		uv.idle_start(idler, on_check)
	end

	immediate_queue[#immediate_queue + 1] = bind(callback, ...)
end

------------------------------------------------------------------------------

local lists = {}

---@class ulf.core.timer.list_node
---@field _idle_next ulf.core.timer.list_node
---@field _idle_prev ulf.core.timer.list_node

---comment
---@param list ulf.core.timer.list_node
local function init(list)
	list._idle_next = list
	list._idle_prev = list
end

---@param list ulf.core.timer.list_node
local function peek(list)
	if list._idle_prev == list then
		return nil
	end
	return list._idle_prev
end

---@param item ulf.core.timer.list_node
local function remove(item)
	if item._idle_next then
		item._idle_next._idle_prev = item._idle_prev
	end

	if item._idle_prev then
		item._idle_prev._idle_next = item._idle_next
	end

	item._idle_next = nil
	item._idle_prev = nil
end

---@param list ulf.core.timer.list_node
---@param item ulf.core.timer.list_node
local function append(list, item)
	remove(item)
	item._idle_next = list._idle_next
	list._idle_next._idle_prev = item
	item._idle_prev = list
	list._idle_next = item
end

---@param list ulf.core.timer.list_node
local function is_empty(list)
	return list._idle_next == list
end

local expiration
---comment
---@param timer ulf.Timer
---@param msecs integer
---@return function
expiration = function(timer, msecs)
	return function()
		local now = Timer.now()
		while peek(timer) do
			local elem = peek(timer)
			local diff = now - elem._idle_start
			if ((diff + 1) < msecs) == true then
				timer:start(msecs - diff, 0, expiration(timer, msecs))
				return
			else
				remove(elem)
				if elem.emit then
					elem:emit("timeout")
				end
			end
		end

		-- Remove the timer if it wasn't already
		-- removed by unenroll
		local list = lists[msecs]
		if list and is_empty(list) then
			list:stop()
			list:close()
			lists[msecs] = nil
		end
	end
end

local function _insert(item, msecs)
	item._idle_start = Timer.now()
	item._idle_timeout = msecs

	if msecs < 0 then
		return
	end

	local list

	if lists[msecs] then
		list = lists[msecs]
	else
		list = Timer:new()
		init(list)
		list:start(msecs, 0, expiration(list, msecs))
		lists[msecs] = list
	end

	append(list, item)
end

local function unenroll(item)
	remove(item)
	local list = lists[item._idle_timeout]
	if list and is_empty(list) then
		-- empty list
		list:stop()
		list:close()
		lists[item._idle_timeout] = nil
	end
	item._idle_timeout = -1
end

-- does not start the timer, just initializes the item
local function enroll(item, msecs)
	if item._idle_next then
		unenroll(item)
	end
	item._idle_timeout = msecs
	init(item)
end

-- call this whenever the item is active (not idle)
---comment
---@param item any
local function active(item)
	local msecs = item._idle_timeout
	if msecs and msecs >= 0 then
		local list = lists[msecs]
		if not list or is_empty(list) then
			_insert(item, msecs)
		else
			item._idle_start = Timer.now()
			append(lists[msecs], item)
		end
	end
end

return {
	sleep = sleep,
	set_timeout = set_timeout,
	set_interval = set_interval,
	clear_interval = clear_interval,
	clear_timeout = clear_interval,
	clear_timer = clear_interval, -- Luvit 1.x compatibility
	set_immediate = set_immediate,
	unenroll = unenroll,
	enroll = enroll,
	active = active,
}
