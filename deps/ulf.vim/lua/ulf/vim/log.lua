return setmetatable({}, {

	__index = function(t, k)
		require("ulf.log").register("ulf.vim", require("ulf.vim.config").logging_defaults)
		---@type ulf.ILogManager
		local Logger = require("ulf.vim.logger")
		rawset(t, k, Logger)
		setmetatable(t, nil)
		return Logger
	end,
})
