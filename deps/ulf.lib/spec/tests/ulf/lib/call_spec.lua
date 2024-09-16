local stub = require("luassert.stub")
local mock = require("luassert.mock")
local uv = mock(vim and vim.uv or require("luv"), true)

local validator = {}

---comment
---@param got {handler_was_called:boolean,msg:string}
---@param expect {handler_was_called:boolean,msg_pattern:string,stack_trace_pattern:string}
validator.error_with_stack_trace = function(got, expect)
	assert(got.handler_was_called == expect.handler_was_called)
	assert(
		got.msg:match(expect.msg_pattern),
		"ulf.lib.call: try: expect msg_pattern='" .. expect.msg_pattern .. "' to match got.msg='" .. got.msg .. "'"
	)
	assert(
		got.msg:match(expect.stack_trace_pattern),
		"ulf.lib.call: try: expect stack_trace_pattern='"
			.. expect.stack_trace_pattern
			.. "' to match got.msg='"
			.. got.msg
			.. "'"
	)
end

describe("#ulf.lib", function()
	describe("#ulf.lib.call", function()
		local orig = {
			uv = {},
		}
		before_each(function()
			uv.os_homedir.returns("/home/test")
		end)
		local Call = require("ulf.lib.call")
		describe("try", function()
			it("catches an error if no handler is given", function()
				local failed = function()
					return error("test-error")
				end
				assert.has_no_error(function()
					Call.try(failed)
				end)
				assert.has_error(function()
					failed()
				end)
			end)
			it("calls the error handler if opts.on_error is a function", function()
				local failed = function()
					return error("try testerror")
				end
				local handler_was_called = false
				local got_msg = ""
				Call.try(failed, {
					on_error = function(msg)
						handler_was_called = true
						got_msg = msg
					end,
				})
				validator.error_with_stack_trace({
					msg = got_msg,
					handler_was_called = handler_was_called,
				}, {
					handler_was_called = true,
					msg_pattern = ".*try testerror.*",
					stack_trace_pattern = "ulf%/lib%/call.lua:%d+",
				})
			end)

			-- TODO: handle errors asynconously
			-- it("calls the error handler asynconously if opts.on_error is a function", function() end)
		end)
	end)
end)
