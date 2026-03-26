---@module "worktrunk.config"
---Backward compatibility shim - delegates to config.internal
---DEPRECATED: Use require("worktrunk.config.internal") instead

local internal = require("worktrunk.config.internal")

local M = {}

---Setup the configuration (backward compatible)
---@param opts table|nil
function M.setup(opts)
  internal.setup(opts)
end

---Get the current configuration (backward compatible)
---@return table|nil
function M.get()
  return internal.get()
end

return M
