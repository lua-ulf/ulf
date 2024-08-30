local M = {}
local uv = vim and vim.uv or require("luv")
function M.rm(path)
	local res, err = uv.fs_unlink(path)
	assert(res)
	assert(err == nil)
end

return M
