---@module "worktrunk.ui.notify"
---Standardized notification system for worktrunk.nvim

local M = {}

---@enum worktrunk.NotifyLevel
M.LEVEL = {
  DEBUG = vim.log.levels.DEBUG,
  INFO = vim.log.levels.INFO,
  WARN = vim.log.levels.WARN,
  ERROR = vim.log.levels.ERROR,
}

---Send a notification
---@param message string
---@param level worktrunk.NotifyLevel
function M.notify(message, level)
  vim.notify(message, level or M.LEVEL.INFO, { title = "worktrunk.nvim" })
end

---Send an info notification
---@param message string
function M.info(message)
  M.notify(message, M.LEVEL.INFO)
end

---Send a warning notification
---@param message string
function M.warn(message)
  M.notify(message, M.LEVEL.WARN)
end

---Send an error notification
---@param message string
function M.error(message)
  M.notify(message, M.LEVEL.ERROR)
end

---Send a debug notification
---@param message string
function M.debug(message)
  M.notify(message, M.LEVEL.DEBUG)
end

---Notify about operation success
---@param operation string
function M.success(operation)
  M.info(operation .. " completed successfully")
end

---Notify about operation failure with error
---@param operation string
---@param err string
function M.failure(operation, err)
  M.error(operation .. " failed: " .. err)
end

---Echo a message to the command line (not a notification)
---@param message string
---@param hl_group string|nil
function M.echo(message, hl_group)
  hl_group = hl_group or "Normal"
  vim.api.nvim_echo({{ message, hl_group }}, false, {})
end

return M
