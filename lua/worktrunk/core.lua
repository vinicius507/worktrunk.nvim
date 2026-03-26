---@module "worktrunk.core"
---Backward compatibility shim - delegates to api.cli
---DEPRECATED: Use require("worktrunk.api.cli") instead

local cli = require("worktrunk.api.cli")
local M = {}

---Parse error from stderr
---@param stderr string|nil
---@return string
function M.parse_error(stderr)
  return require("worktrunk.util.error").parse_error(stderr)
end

---List all worktrees
---@param opts table|nil
---@return worktrunk.Worktree[]
function M.list(opts)
  local ok, result = cli.list(opts)
  if not ok then
    return {}
  end
  return result
end

---Switch to a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.switch(branch, opts)
  local ok, _ = cli.switch(branch, opts)
  return ok
end

---Create a new worktree
---@param branch string
---@param base string|nil
---@param opts table|nil
---@return boolean
function M.create(branch, base, opts)
  local ok, _ = cli.create(branch, base, opts)
  return ok
end

---Remove a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.remove(branch, opts)
  local ok, _ = cli.remove(branch, opts)
  return ok
end

---Get current worktree
---@return worktrunk.Worktree|nil
function M.current()
  local ok, result = cli.current()
  if not ok then
    return nil
  end
  return result
end

---Merge current branch into target
---@param target string|nil
---@param opts table|nil
---@return boolean
function M.merge(target, opts)
  local ok, _ = cli.merge(target, opts)
  return ok
end

---Run a step command
---@param subcommand string
---@param opts table|nil
---@return boolean
function M.step(subcommand, opts)
  local ok, _ = cli.step(subcommand, opts)
  return ok
end

return M
