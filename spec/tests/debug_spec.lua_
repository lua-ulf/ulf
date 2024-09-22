-- require("ulf").util.debug._G()
-- local ulf = require("ulf")
-- P({
-- 	"debug ulf",
-- 	ulf = ulf or "nil",
-- })
local mock = require("luassert.mock")
local packages = {

	async = true,
	core = true,
	doc = true,
	lib = true,
	log = true,
	luvit = true,
	process = true,
	sys = true,
	test = true,
	util = true,
	vim = true,
}

local busted = require("busted")
local debug_lib = require("ulfboot.debug")

local io_mock = mock(io)
describe("#ulf #ulfboot", function()
	local orig = {
		uv = {},
	}
	before_each(function()
		-- io_mock.flush.returns("/home/test")
	end)

	describe("#ulf #ulfboot ulf.lib.debug module", function()
		-- describe("inspect function", function()
		-- 	it("uses fallback inspect implementation when vim.inspect is unavailable", function()
		-- 		local original_vim = vim
		-- 		vim = nil -- temporarily remove vim to simulate environment without it
		--
		-- 		assert.has_error(function()
		-- 			debug_lib.inspect("test")
		-- 		end, "[ulfboot.debug].inspect: inspect module not found")
		--
		-- 		vim = original_vim -- restore vim
		-- 	end)
		--
		-- 	it("uses vim.inspect when available", function()
		-- 		local original_vim = vim
		-- 		vim = {
		-- 			inspect = function(...)
		-- 				return "inspected: " .. tostring(...)
		-- 			end,
		-- 		} -- mock vim.inspect
		--
		-- 		local result = debug_lib.inspect("test")
		-- 		assert.are.equal(result, "inspected: test")
		--
		-- 		vim = original_vim -- restore vim
		-- 	end)
		-- end)

		describe("debug_print function", function()
			it("prints inspected values", function()
				local output = {}

				-- Mock io.write to capture output
				io.write = function(text)
					table.insert(output, text)
				end

				debug_lib.debug_print("header", 42, true, { key = "value" })

				local expected = "header 2 (number) 42 3 (boolean) true 4 (table) {\n"
				debug_lib.debug_print(expected)
				-- assert.are.equal(table.concat(output, ""), expected)

				-- Reset io.write to original function
				io.write = io.stdout.write
			end)

			-- it("does nothing if no arguments are passed", function()
			-- 	local output = {}
			--
			-- 	-- Mock io.write to capture output
			-- 	io.write = function(text)
			-- 		table.insert(output, text)
			-- 	end
			--
			-- 	debug_lib.debug_print() -- No arguments
			--
			-- 	assert.are.equal(#output, 0) -- Ensure nothing was printed
			--
			-- 	-- Reset io.write to original function
			-- 	io.write = io.stdout.write
			-- end)
		end)

		describe("dump function", function()
			it("dumps a string", function()
				local result = debug_lib.dump("test string")
				assert.are.equal(result, '"test string"')
			end)

			it("dumps a table with numeric keys", function()
				local result = debug_lib.dump({ 1, 2, 3 })
				assert.are.equal(result, "{1,2,3,}")
			end)

			it("dumps a table with string keys", function()
				local result = debug_lib.dump({ key = "value" })
				assert.are.equal(result, '{key="value",}')
			end)

			it("handles unsupported types with an error", function()
				assert.has_error(function()
					debug_lib.dump(function() end)
				end, "Unsupported type function")
			end)
		end)
		--
		describe("_G function", function()
			it("sets P and pp in the global environment", function()
				local env = {}
				debug_lib._G(env)

				assert.is_not_nil(env.P)
				assert.is_not_nil(env.pp)

				assert.are.equal(type(env.P), "function")
				assert.are.equal(type(env.pp), "function")
			end)

			it("sets P and pp in _G by default", function()
				debug_lib._G() -- Defaults to _G

				assert.is_not_nil(_G.P)
				assert.is_not_nil(_G.pp)

				assert.are.equal(type(_G.P), "function")
				assert.are.equal(type(_G.pp), "function")
			end)
		end)
	end)
end)
