-- local t = require("test.testutil")
-- local eq = t.eq
if false then
	local T = {}

	T.luacats = function()
		local parser = require("ulf.doc.lib.luacats.luacats_parser")

		local result = parser.parse("/Users/al/dev/projects/ulf/deps/ulf.doc/lua/ulf/doc/defaults.lua")
		P(result)
	end

	T.ulf = function()
		require("ulf")
		P({
			"T.ulf______________",
			ulf = ulf,
			ulf_doc = ulf.doc,
		})
	end
	-- T.luacats()
	T.ulf()
end
