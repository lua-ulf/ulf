---@class ulf.core.minilib
local minilib = {}

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
--- @param path string path argument
--- @return string?
function minilib.basename(path)
	return path:match(".*" .. minilib.pattern_escape(minilib.pathsep) .. "(.+)$")
end

--- returns the dirname of a path
--- @param path string path argument
--- @return string?
function minilib.dirname(path)
	return path:match("(.*)" .. minilib.pattern_escape(minilib.pathsep) .. ".+$")
end

--- creates a directory
--- @param path string path to directory
--- @return boolean?
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
--- @param path string path to directory
--- @return boolean?
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

return minilib
