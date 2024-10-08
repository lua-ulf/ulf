---@meta
-- ---@diagnostic disable: duplicate-set-field
-- local ulf
--
-- ---@class ulf.InitOptions
--
-- ---@class ulf.logger
-- ---@field root ulf.ILogManager The global LogMamanger
-- ---@field child {[string]:ulf.ILogManager} LogMamangers for packages
--
-- ---@class ulf
-- ---@field initialized boolean This flag is set once the init() function has been called.
-- ---@field core ulf.core
-- ---@field logger ulf.logger References to all LogMamangers
-- ---@field doc ulf.doc
-- ---@field init fun(opts:ulf.InitOptions)
-- ---@field process ulf.GlobalProcess
-- return ulf
