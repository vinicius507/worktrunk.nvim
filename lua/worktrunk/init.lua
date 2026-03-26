---@module "worktrunk"
local M = {}

local initialized = false

---Ensure plugin is initialized
---@return boolean
function M._ensure_initialized()
  if initialized then
    return true
  end

  local opts = vim.g.worktrunk or {}
  M.setup(opts)
  return true
end

---Setup the plugin
---@param opts table|nil
function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}

  local config = require("worktrunk.config")
  config.setup(opts)

  initialized = true
end

---List all worktrees
---@param opts table|nil
---@return table[]
function M.list(opts)
  M._ensure_initialized()
  return require("worktrunk.core").list(opts)
end

---Switch to a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.switch(branch, opts)
  M._ensure_initialized()
  return require("worktrunk.core").switch(branch, opts)
end

---Merge current branch into target
---@param target string|nil
---@param opts table|nil
---@return boolean
function M.merge(target, opts)
  M._ensure_initialized()
  return require("worktrunk.core").merge(target, opts)
end

---Run a step command
---@param subcommand string
---@param opts table|nil
---@return boolean
function M.step(subcommand, opts)
  M._ensure_initialized()
  return require("worktrunk.core").step(subcommand, opts)
end

---Remove a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.remove(branch, opts)
  M._ensure_initialized()
  return require("worktrunk.core").remove(branch, opts)
end

---Run a hook
---@param hook_type string
---@param opts table|nil
function M.run_hook(hook_type, opts)
  M._ensure_initialized()
  vim.notify("Running hook: " .. hook_type, vim.log.levels.INFO)
end

---Get current worktree
---@return table|nil
function M.current()
  M._ensure_initialized()
  return require("worktrunk.core").current()
end

---Get statusline component
---@return string
function M.statusline()
  local current = M.current()
  if current then
    return " " .. current.branch
  end
  return ""
end

return M
