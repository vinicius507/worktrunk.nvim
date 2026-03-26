---@module "worktrunk.api.cli"
---CLI API for worktrunk.nvim - wraps wt CLI commands

local M = {}

---Execute a worktrunk command
---@param args string[]
---@return table|nil result
---@return string|nil error
local function exec(args)
  local config = require("worktrunk.config.internal").get()
  local wt_cmd = config.wt_cmd
  local cmd = vim.list_extend({ wt_cmd }, args)

  local ok, result = pcall(vim.system, cmd, { text = true })
  if not ok then
    return nil, "Failed to execute command: " .. tostring(result)
  end

  local wait_ok, output = pcall(function()
    return result:wait()
  end)

  if not wait_ok then
    return nil, "Command execution failed: " .. tostring(output)
  end

  return output, nil
end

---Parse error from stderr
---@param stderr string|nil
---@return string error_type
local function parse_error(stderr)
  return require("worktrunk.util.error").parse_error(stderr)
end

---List all worktrees
---@param opts table|nil
---@return boolean ok
---@return worktrunk.Worktree[]|string result_or_error
function M.list(opts)
  opts = opts or {}
  local args = { "list", "--format", "json" }

  if opts.branches then
    table.insert(args, "--branches")
  end

  if opts.remotes then
    table.insert(args, "--remotes")
  end

  if opts.full then
    table.insert(args, "--full")
  end

  if opts.progressive then
    table.insert(args, "--progressive")
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type)
  end

  if not result.stdout or result.stdout == "" then
    return true, {}
  end

  local ok, worktrees = pcall(vim.json.decode, result.stdout)
  if not ok then
    return false, "Failed to parse worktree list output"
  end

  return true, worktrees
end

---Switch to a worktree
---@param branch string
---@param opts table|nil
---@return boolean ok
---@return string|nil error
function M.switch(branch, opts)
  opts = opts or {}
  local args = { "switch", branch }

  if opts.create then
    table.insert(args, 2, "--create")
  end

  if opts.base then
    table.insert(args, "--base=" .. opts.base)
  end

  if opts.yes then
    table.insert(args, "--yes")
  end

  if opts.no_verify then
    table.insert(args, "--no-verify")
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type, branch)
  end

  -- Change to the worktree directory if auto_cd is enabled
  local config = require("worktrunk.config.internal").get()
  if config.auto_cd and not opts.no_cd then
    local ok, worktrees = M.list()
    if ok then
      for _, w in ipairs(worktrees) do
        if w.branch == branch or branch:match("^" .. w.branch) then
          vim.cmd("tcd " .. vim.fn.fnameescape(w.path))
          break
        end
      end
    end
  end

  return true, nil
end

---Create a new worktree
---@param branch string
---@param base string|nil
---@param opts table|nil
---@return boolean ok
---@return string|nil error
function M.create(branch, base, opts)
  opts = opts or {}
  local args = { "switch", "--create", branch }

  if base then
    table.insert(args, "--base=" .. base)
  end

  if opts.yes then
    table.insert(args, "--yes")
  end

  if opts.no_verify then
    table.insert(args, "--no-verify")
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type, branch)
  end

  return true, nil
end

---Remove a worktree
---@param branch string
---@param opts table|nil
---@return boolean ok
---@return string|nil error
function M.remove(branch, opts)
  opts = opts or {}
  local args = { "remove", branch }

  if opts.force then
    table.insert(args, "--force")
  end

  if opts.yes then
    table.insert(args, "--yes")
  end

  if opts.no_verify then
    table.insert(args, "--no-verify")
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type, branch)
  end

  return true, nil
end

---Get current worktree
---@return boolean ok
---@return worktrunk.Worktree|nil|string result_or_error
function M.current()
  local ok, result = M.list()
  if not ok then
    return false, result
  end

  local worktrees = result
  for _, worktree in ipairs(worktrees) do
    if worktree.is_current then
      return true, worktree
    end
  end

  return true, nil
end

---Merge current branch into target
---@param target string|nil
---@param opts table|nil
---@return boolean ok
---@return string|nil error
function M.merge(target, opts)
  opts = opts or {}
  local args = { "merge" }

  if target then
    table.insert(args, target)
  end

  if opts.no_squash then
    table.insert(args, "--no-squash")
  end

  if opts.no_commit then
    table.insert(args, "--no-commit")
  end

  if opts.no_rebase then
    table.insert(args, "--no-rebase")
  end

  if opts.no_remove then
    table.insert(args, "--no-remove")
  end

  if opts.no_ff then
    table.insert(args, "--no-ff")
  end

  if opts.stage then
    table.insert(args, "--stage=" .. opts.stage)
  end

  if opts.yes then
    table.insert(args, "--yes")
  end

  if opts.no_verify then
    table.insert(args, "--no-verify")
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type, target)
  end

  return true, nil
end

---Run a step command
---@param subcommand string
---@param opts table|nil
---@return boolean ok
---@return string|nil error
function M.step(subcommand, opts)
  opts = opts or {}
  local args = { "step", subcommand }

  if opts.stage then
    table.insert(args, "--stage=" .. opts.stage)
  end

  local result, err = exec(args)
  if err then
    return false, err
  end

  if not result then
    return false, "No result from CLI"
  end

  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)
    return false, require("worktrunk.util.error").get_message(error_type)
  end

  return true, nil
end

return M
