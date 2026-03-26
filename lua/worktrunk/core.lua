---@module "worktrunk.core"
local M = {}

---@class worktrunk.Commit
---@field sha string
---@field short_sha string
---@field message string
---@field timestamp number

---@class worktrunk.WorkingTree
---@field staged boolean
---@field modified boolean
---@field untracked boolean
---@field renamed boolean
---@field deleted boolean
---@field diff { added: number, deleted: number }

---@class worktrunk.Worktree
---@field branch string
---@field path string
---@field kind string "worktree" or "branch"
---@field commit worktrunk.Commit|nil
---@field working_tree worktrunk.WorkingTree|nil
---@field main_state string|nil
---@field is_main boolean
---@field is_current boolean
---@field is_previous boolean
---@field symbols string

---Parse error from stderr
---@param stderr string|nil
---@return string
function M.parse_error(stderr)
  if not stderr then
    return "unknown"
  end

  if stderr:match("branch.*not found") then
    return "branch_not_found"
  elseif stderr:match("worktree already exists") then
    return "worktree_exists"
  elseif stderr:match("uncommitted changes") then
    return "dirty_worktree"
  end

  return "unknown"
end

---Execute a worktrunk command
---@param args string[]
---@return table result
local function exec(args)
  local config = require("worktrunk.config").get()
  local wt_cmd = config and config.wt_cmd or "wt"
  local cmd = vim.list_extend({ wt_cmd }, args)

  local result = vim.system(cmd, { text = true }):wait()
  return result
end

---List all worktrees
---@return worktrunk.Worktree[]
function M.list()
  local result = exec({ "list", "--format", "json" })

  if result.code ~= 0 then
    return {}
  end

  if not result.stdout or result.stdout == "" then
    return {}
  end

  local ok, worktrees = pcall(vim.json.decode, result.stdout)
  if not ok then
    vim.notify("worktrunk: failed to parse list output", vim.log.levels.ERROR)
    return {}
  end

  return worktrees
end

---Switch to a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.switch(branch, opts)
  opts = opts or {}
  local args = { "switch", branch }

  if opts.create then
    table.insert(args, 2, "--create")
  end

  local result = exec(args)
  if result.code ~= 0 then
    return false
  end

  -- Change to the worktree directory using :tcd (tab cd)
  local config = require("worktrunk.config").get()
  if config and config.auto_cd then
    local worktrees = M.list()
    for _, w in ipairs(worktrees) do
      if w.branch == branch or branch:match("^" .. w.branch) then
        vim.cmd("tcd " .. vim.fn.fnameescape(w.path))
        break
      end
    end
  end

  return true
end

---Create a new worktree
---@param branch string
---@param base string|nil
---@param opts table|nil
---@return boolean
function M.create(branch, base, opts)
  opts = opts or {}
  local args = { "switch", "--create", branch }

  if base then
    table.insert(args, "--base=" .. base)
  end

  local result = exec(args)
  return result.code == 0
end

---Remove a worktree
---@param branch string
---@param opts table|nil
---@return boolean
function M.remove(branch, opts)
  opts = opts or {}
  local args = { "remove", branch }

  if opts.force then
    table.insert(args, "--force")
  end

  local result = exec(args)
  return result.code == 0
end

---Get current worktree
---@return worktrunk.Worktree|nil
function M.current()
  local worktrees = M.list()

  for _, worktree in ipairs(worktrees) do
    if worktree.is_current then
      return worktree
    end
  end

  return nil
end

return M
