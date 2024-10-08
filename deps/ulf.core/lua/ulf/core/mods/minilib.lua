---@brief [[
--- minilib contains functions for setting up configuration data (useful in plugin init)
---
---@brief ]]

---@tag ulf.core.mod.minilib
---@config { ["name"] = "ULF.CORE.MINILIB" }
---

---
---@class ulf.core.minilib
local minilib = {}

local imports = {
	string = require("ulf.core.mods._minilib.string"),
}

minilib.trim = imports.string.trim
minilib.strlen = imports.string.strlen
minilib.gsplit = imports.string.gsplit
minilib.split = imports.string.split

local NIL = vim and vim.NIL or "\0"

local uv = vim and vim.uv or require("luv")

minilib.is_windows = package.config:find("\\") and true or false
minilib.pathsep = minilib.is_windows and "\\" or "/"

function minilib.pattern_escape(str)
	return str:gsub("([%(%)%.%/%%%+%-%*%?%[%^%$])", "%%%1")
end

--- joins a list of strings to a valid path
---@param ... string path elements to join
---@return string?
function minilib.joinpath(...)
	return (table.concat({ ... }, minilib.pathsep):gsub(minilib.pathsep .. minilib.pathsep .. "+", minilib.pathsep))
end

--- returns the basename of a path
---@param path string path argument
---@return string?
function minilib.basename(path)
	return path:match(".*" .. minilib.pattern_escape(minilib.pathsep) .. "(.+)$")
end

--- returns the dirname of a path
---@param path string path argument
---@return string?
function minilib.dirname(path)
	return path:match("(.*)" .. minilib.pattern_escape(minilib.pathsep) .. ".+$")
end

--- creates a directory
---@param path string path to directory
---@return boolean?
function minilib.mkdir(path)
	-- 493 is 0755 in decimal
	local err, res = uv.fs_mkdir(path, 493)

	if err and type(err) ~= "boolean" then
		error(err)
	end
	return true
end

--- removes a directory
---@param path string directory to remove
function minilib.rmdir(path)
	assert(uv.fs_rmdir(path))
end

--- tests if directory exists
---@param path string path to directory
---@return boolean?
function minilib.dir_exists(path)
	local stat = uv.fs_stat(path)

	if not stat then
		return false
	end
	if type(stat) == "table" then
		return stat.type == "directory"
	end
end

function minilib.file_exists(file)
	return uv.fs_stat(file) ~= nil
end

---comment
---@param fname string
---@return string
function minilib.read_file(fname)
	local fd = assert(io.open(fname, "r"))
	---@type string
	local data = fd:read("*a")
	fd:close()
	return data
end

-- Function to get the git root directory
---@return string|nil
function minilib.git_root()
	---@type string
	local git_root
	---@type file*
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if handle then
		---@type string
		git_root = handle:read("*a"):gsub("\n", "")
		handle:close()
	end
	return git_root
end

--================================================================================
-- TABLES
--================================================================================

--- Tests if `t` is an "array": a table indexed _only_ by integers
--- (potentially non-contiguous). If the indexes start from 1 and
--- are contiguous then the array is also a list.
--- @see M.islist()
---
--- Empty table `{}` is an array, too.
---
---@see https://github.com/openresty/luajit2#tableisarray
---
---@param t? table
---@return boolean `true` if array-like table, else `false`.
function minilib.isarray(t)
	if type(t) ~= "table" then
		return false
	end

	if minilib.islist(t) then
		return true
	end

	--- @cast t table<any,any>

	local count = 0

	for k, _ in pairs(t) do
		-- Check if the number k is an integer
		if type(k) == "number" and k == math.floor(k) then
			count = count + 1
		else
			return false
		end
	end

	if count > 0 then
		return true
	end
	return false
end

--- Tests if `t` is a "list": a table indexed _only_ by contiguous integers starting
--- from 1 (what lua-length calls a "regular array").
---
--- Empty table `{}` is a list, too.
---
---@see M.isarray()
---
---@param t? table
---@return boolean `true` if list-like table, else `false`.
function minilib.islist(t)
	if type(t) ~= "table" then
		return false
	end

	local j = 1
	for _ in
		pairs(t--[[@as table<any,any>]])
	do
		if t[j] == nil then
			return false
		end
		j = j + 1
	end

	return true
end

---@generic T
---@param orig T
---@param cache? table<any,any>
---@return T
local function deepcopy(orig, cache)
	if orig == NIL then
		return NIL
	elseif type(orig) == "userdata" or type(orig) == "thread" then
		error("Cannot deepcopy object of type " .. type(orig))
	elseif type(orig) ~= "table" then
		return orig
	end

	--- @cast orig table<any,any>

	if cache and cache[orig] then
		return cache[orig]
	end

	local copy = {} --- @type table<any,any>

	if cache then
		cache[orig] = copy
	end

	for k, v in pairs(orig) do
		copy[deepcopy(k, cache)] = deepcopy(v, cache)
	end

	return setmetatable(copy, getmetatable(orig))
end

--- Returns a deep copy of the given object. Non-table objects are copied as
--- in a typical Lua assignment, whereas table objects are copied recursively.
--- Functions are naively copied, so functions in the copied table point to the
--- same functions as those in the input table. Userdata and threads are not
--- copied and will throw an error.
---
--- Note: `noref=true` is much more performant on tables with unique table
--- fields, while `noref=false` is more performant on tables that reuse table
--- fields.
---
---@generic T: table
---@param orig T Table to copy
---@param noref? boolean
--- When `false` (default) a contained table is only copied once and all
--- references point to this single copy. When `true` every occurrence of a
--- table results in a new copy. This also means that a cyclic reference can
--- cause `deepcopy()` to fail.
---@return T Table of copied keys and (nested) values.
function minilib.deepcopy(orig, noref)
	return deepcopy(orig, not noref and {} or nil)
end

--- Deep compare values for equality
---
--- Tables are compared recursively unless they both provide the `eq` metamethod.
--- All other types are compared using the equality `==` operator.
---@param a any First value
---@param b any Second value
---@return boolean `true` if values are equals, else `false`
function minilib.deep_equal(a, b)
	if a == b then
		return true
	end
	if type(a) ~= type(b) then
		return false
	end
	if type(a) == "table" then
		--- @cast a table<any,any>
		--- @cast b table<any,any>
		for k, v in pairs(a) do
			if not vim.deep_equal(v, b[k]) then
				return false
			end
		end
		for k in pairs(b) do
			if a[k] == nil then
				return false
			end
		end
		return true
	end
	return false
end

--- Checks if a table is empty.
---
---@see https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@param t table Table to check
---@return boolean `true` if `t` is empty
function minilib.tbl_isempty(t)
	assert(type(t) == "table", "M.tbl_isempty: expected t as table")
	return next(t) == nil
end

--- We only merge empty tables or tables that are not an array (indexed by integers)
local function can_merge(v)
	return type(v) == "table" and (minilib.tbl_isempty(v) or not minilib.isarray(v))
end

local function tbl_extend(behavior, deep_extend, ...)
	if behavior ~= "error" and behavior ~= "keep" and behavior ~= "force" then
		error('invalid "behavior": ' .. tostring(behavior))
	end

	if select("#", ...) < 2 then
		error("wrong number of arguments (given " .. tostring(1 + select("#", ...)) .. ", expected at least 3)")
	end

	local ret = {} --- @type table<any,any>

	for i = 1, select("#", ...) do
		local tbl = select(i, ...)
		assert(type(tbl) == "table", "M.tbl_extend: expected tbl as table")
		--- @cast tbl table<any,any>
		if tbl then
			for k, v in pairs(tbl) do
				if deep_extend and can_merge(v) and can_merge(ret[k]) then
					ret[k] = tbl_extend(behavior, true, ret[k], v)
				elseif behavior ~= "force" and ret[k] ~= nil then
					if behavior == "error" then
						error("key found in more than one map: " .. k)
					end -- Else behavior is "keep".
				else
					ret[k] = v
				end
			end
		end
	end
	return ret
end

--- Merges two or more tables.
---
---@see extend()
---
---@param behavior 'error'|'keep'|'force' Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... table Two or more tables
---@return table : Merged table
function minilib.tbl_extend(behavior, ...)
	return tbl_extend(behavior, false, ...)
end

--- Merges recursively two or more tables.
---
---@see M.tbl_extend()
---
---@generic T1: table
---@generic T2: table
---@param behavior 'error'|'keep'|'force' Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... T2 Two or more tables
---@return T1|T2 (table) Merged table
function minilib.tbl_deep_extend(behavior, ...)
	return tbl_extend(behavior, true, ...)
end

--- Return a list of all keys used in a table.
--- However, the order of the return table of keys is not guaranteed.
---
---@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@generic T
---@param t table<T, any> (table) Table
---@return T[] : List of keys
function minilib.tbl_keys(t)
	assert(type(t) == "table", "M.tbl_values: expect t to be a table")
	--- @cast t table<any,any>

	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

--- Return a list of all values used in a table.
--- However, the order of the return table of values is not guaranteed.
---
---@generic T
---@param t table<any, T> (table) Table
---@return T[] : List of values
function minilib.tbl_values(t)
	assert(type(t) == "table", "M.tbl_values: expect t to be a table")

	local values = {}
	for _, v in
		pairs(t --[[@as table<any,any>]])
	do
		table.insert(values, v)
	end
	return values
end

return minilib
