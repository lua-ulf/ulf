---@tag ulf.lib.table.validate

---@source neovim/runtime/lua/vim/shared.lua#validate
---

local is_callable = require("ulf.lib.types.is_callable")
local spairs = require("ulf.lib.table.spairs")

local ulf = {}
do
	--- @alias ulf.validate.Type
	--- | 't' | 'table'
	--- | 's' | 'string'
	--- | 'n' | 'number'
	--- | 'f' | 'function'
	--- | 'c' | 'callable'
	--- | 'nil'
	--- | 'thread'
	--- | 'userdata

	local type_names = {
		["table"] = "table",
		t = "table",
		["string"] = "string",
		s = "string",
		["number"] = "number",
		n = "number",
		["boolean"] = "boolean",
		b = "boolean",
		["function"] = "function",
		f = "function",
		["callable"] = "callable",
		c = "callable",
		["nil"] = "nil",
		["thread"] = "thread",
		["userdata"] = "userdata",
	}

	--- @nodoc
	--- @class ulf.validate.Spec [any, string|string[], boolean]
	--- @field [1] any Argument value
	--- @field [2] string|string[]|fun(v:any):boolean, string? Type name, or callable
	--- @field [3]? boolean

	local function _is_type(val, t)
		return type(val) == t or (t == "callable" and is_callable(val))
	end

	--- @param param_name string
	--- @param spec ulf.validate.Spec
	--- @return string?
	local function is_param_valid(param_name, spec)
		if type(spec) ~= "table" then
			return string.format("opt[%s]: expected table, got %s", param_name, type(spec))
		end

		local val = spec[1] -- Argument value
		local types = spec[2] -- Type name, or callable
		local optional = (true == spec[3])

		if type(types) == "string" then
			types = { types }
		end

		if is_callable(types) then
			-- Check user-provided validation function
			local valid, optional_message = types(val)
			if not valid then
				local error_message =
					string.format("%s: expected %s, got %s", param_name, (spec[3] or "?"), tostring(val))
				if optional_message ~= nil then
					error_message = string.format("%s. Info: %s", error_message, optional_message)
				end

				return error_message
			end
		elseif type(types) == "table" then
			local success = false
			for i, t in ipairs(types) do
				local t_name = type_names[t]
				if not t_name then
					return string.format("invalid type name: %s", t)
				end
				types[i] = t_name

				if (optional and val == nil) or _is_type(val, t_name) then
					success = true
					break
				end
			end
			if not success then
				return string.format("%s: expected %s, got %s", param_name, table.concat(types, "|"), type(val))
			end
		else
			return string.format("invalid type name: %s", tostring(types))
		end
	end

	--- @param opt table<ulf.validate.Type,ulf.validate.Spec>
	--- @return boolean, string?
	local function is_valid(opt)
		if type(opt) ~= "table" then
			return false, string.format("opt: expected table, got %s", type(opt))
		end

		local report --- @type table<string,string>?

		for param_name, spec in pairs(opt) do
			local msg = is_param_valid(param_name, spec)
			if msg then
				report = report or {}
				report[param_name] = msg
			end
		end

		if report then
			for _, msg in spairs(report) do -- luacheck: ignore
				return false, msg
			end
		end

		return true
	end

	--- Validate function arguments.
	---
	--- This function has two valid forms:
	---
	--- 1. ulf.validate(name: str, value: any, type: string, optional?: bool)
	--- 2. ulf.validate(spec: table)
	---
	--- Form 1 validates that argument {name} with value {value} has the type
	--- {type}. {type} must be a value returned by |lua-type()|. If {optional} is
	--- true, then {value} may be null. This form is significantly faster and
	--- should be preferred for simple cases.
	---
	--- Example:
	---
	--- ```lua
	--- function ulf.startswith(s, prefix)
	---   ulf.validate('s', s, 'string')
	---   ulf.validate('prefix', prefix, 'string')
	---   ...
	--- end
	--- ```
	---
	--- Form 2 validates a parameter specification (types and values). Specs are
	--- evaluated in alphanumeric order, until the first failure.
	---
	--- Usage example:
	---
	--- ```lua
	--- function user.new(name, age, hobbies)
	---   ulf.validate{
	---     name={name, 'string'},
	---     age={age, 'number'},
	---     hobbies={hobbies, 'table'},
	---   }
	---   ...
	--- end
	--- ```
	---
	--- Examples with explicit argument values (can be run directly):
	---
	--- ```lua
	--- ulf.validate{arg1={{'foo'}, 'table'}, arg2={'foo', 'string'}}
	---    --> NOP (success)
	---
	--- ulf.validate{arg1={1, 'table'}}
	---    --> error('arg1: expected table, got number')
	---
	--- ulf.validate{arg1={3, function(a) return (a % 2) == 0 end, 'even number'}}
	---    --> error('arg1: expected even number, got 3')
	--- ```
	---
	--- If multiple types are valid they can be given as a list.
	---
	--- ```lua
	--- ulf.validate{arg1={{'foo'}, {'table', 'string'}}, arg2={'foo', {'table', 'string'}}}
	--- -- NOP (success)
	---
	--- ulf.validate{arg1={1, {'string', 'table'}}}
	--- -- error('arg1: expected string|table, got number')
	--- ```
	---
	---@param opt table<ulf.validate.Type,ulf.validate.Spec> (table) Names of parameters to validate. Each key is a parameter
	---          name; each value is a tuple in one of these forms:
	---          1. (arg_value, type_name, optional)
	---             - arg_value: argument value
	---             - type_name: string|table type name, one of: ("table", "t", "string",
	---               "s", "number", "n", "boolean", "b", "function", "f", "nil",
	---               "thread", "userdata") or list of them.
	---             - optional: (optional) boolean, if true, `nil` is valid
	---          2. (arg_value, fn, msg)
	---             - arg_value: argument value
	---             - fn: any function accepting one argument, returns true if and
	---               only if the argument is valid. Can optionally return an additional
	---               informative error message as the second returned value.
	---             - msg: (optional) error string if validation fails
	--- @overload fun(name: string, val: any, expected: string, optional?: boolean)
	function ulf.validate(opt, ...)
		local ok = false
		local err_msg ---@type string?
		local narg = select("#", ...)
		if narg == 0 then
			ok, err_msg = is_valid(opt)
		elseif narg >= 2 then
			-- Overloaded signature for fast/simple cases
			local name = opt --[[@as string]]
			local v, expected, optional = ... ---@type string, string, boolean?
			local actual = type(v)

			ok = (actual == expected) or (v == nil and optional == true)
			if not ok then
				err_msg = ("%s: expected %s, got %s%s"):format(name, expected, actual, v and (" (%s)"):format(v) or "")
			end
		else
			error("invalid arguments")
		end

		if not ok then
			error(err_msg, 2)
		end
	end
end

return ulf.validate
