---@module "worktrunk"
---Main module for worktrunk.nvim - Public API

local M = {}

---Plugin initialized state
---@type boolean
local initialized = false

---Ensure plugin is initialized (lazy initialization)
---This function is called automatically when needed
---@return boolean
function M._ensure_initialized()
  if initialized then
    return true
  end

  local opts = vim.g.worktrunk or {}
  M.setup(opts)
  return true
end

---Setup the plugin with user configuration
---Call this function explicitly to configure the plugin,
---or set vim.g.worktrunk for automatic initialization
---@param opts worktrunk.ConfigMeta|nil User configuration options
function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}

  local config = require("worktrunk.config.internal")
  config.setup(opts)

  initialized = true
end

---List all worktrees
---@param opts table|nil Options for listing
---@return boolean ok
---@return worktrunk.Worktree[]|string result_or_error
function M.list(opts)
  M._ensure_initialized()
  return require("worktrunk.api.cli").list(opts)
end

---Switch to a worktree
---@param branch string Branch name to switch to
---@param opts table|nil Options including create, base, etc.
---@return boolean ok
---@return string|nil error
function M.switch(branch, opts)
  M._ensure_initialized()
  return require("worktrunk.api.cli").switch(branch, opts)
end

---Create a new worktree
---@param branch string Branch name for the new worktree
---@param base string|nil Base branch to create from
---@param opts table|nil Additional options
---@return boolean ok
---@return string|nil error
function M.create(branch, base, opts)
  M._ensure_initialized()
  opts = opts or {}
  opts.create = true
  if base then
    opts.base = base
  end
  return require("worktrunk.api.cli").switch(branch, opts)
end

---Merge current branch into target
---@param target string|nil Target branch to merge into
---@param opts table|nil Merge options
---@return boolean ok
---@return string|nil error
function M.merge(target, opts)
  M._ensure_initialized()
  return require("worktrunk.api.cli").merge(target, opts)
end

---Run a step command
---@param subcommand string Step subcommand (commit, squash, rebase, push, diff, copy-ignored)
---@param opts table|nil Step options
---@return boolean ok
---@return string|nil error
function M.step(subcommand, opts)
  M._ensure_initialized()
  return require("worktrunk.api.cli").step(subcommand, opts)
end

---Remove a worktree
---@param branch string Branch name to remove
---@param opts table|nil Remove options
---@return boolean ok
---@return string|nil error
function M.remove(branch, opts)
  M._ensure_initialized()
  return require("worktrunk.api.cli").remove(branch, opts)
end

---Run a hook (placeholder implementation)
---@param hook_type string Type of hook to run
---@param opts table|nil Hook options
function M.run_hook(hook_type, opts)
  M._ensure_initialized()
  -- Hook implementation placeholder
end

---Get current worktree
---@return boolean ok
---@return worktrunk.Worktree|nil|string result_or_error
function M.current()
  M._ensure_initialized()
  return require("worktrunk.api.cli").current()
end

---Get statusline component
---@return string Statusline text showing current branch
function M.statusline()
  local ok, current = M.current()
  if ok and current then
    return "\238\160\160 " .. current.branch
  end
  return ""
end

return M
