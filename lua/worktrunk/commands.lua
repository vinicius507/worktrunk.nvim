---@module "worktrunk.commands"
local M = {}

---Get all worktree branches for completion
---@return string[]
local function get_branches()
  local core = require("worktrunk.core")
  local worktrees = core.list()
  return vim.tbl_map(function(w)
    return w.branch
  end, worktrees)
end

---Complete subcommands
---@param arglead string
---@return string[]
local function complete_subcommands(arglead)
  local subcmds = { "list", "switch", "create", "remove", "hooks", "current" }
  return vim.tbl_filter(function(cmd)
    return vim.startswith(cmd, arglead)
  end, subcmds)
end

---Complete branch names
---@param arglead string
---@return string[]
local function complete_branches(arglead)
  local branches = get_branches()
  return vim.tbl_filter(function(branch)
    return vim.startswith(branch, arglead)
  end, branches)
end

---Complete hook types
---@param arglead string
---@return string[]
local function complete_hooks(arglead)
  local hooks = {
    "pre-switch",
    "post-create",
    "post-start",
    "post-switch",
    "pre-commit",
    "pre-merge",
    "post-merge",
    "pre-remove",
    "post-remove",
  }
  return vim.tbl_filter(function(hook)
    return vim.startswith(hook, arglead)
  end, hooks)
end

---Parse switch command arguments
---@param args string[]
---@return string|nil branch
---@return table opts
function M.parse_switch_args(args)
  local opts = {}
  local branch = nil

  for _, arg in ipairs(args) do
    if arg == "--create" or arg == "-c" then
      opts.create = true
    elseif arg:match("^--base=") then
      opts.base = arg:sub(8)
    elseif arg == "--no-verify" then
      opts.no_verify = true
    elseif not arg:match("^-") and not branch then
      branch = arg
    end
  end

  return branch, opts
end

---Parse remove command arguments
---@param args string[]
---@return string|nil branch
---@return table opts
function M.parse_remove_args(args)
  local opts = {}
  local branch = nil

  for _, arg in ipairs(args) do
    if arg == "--force" or arg == "-f" then
      opts.force = true
    elseif not arg:match("^-") and not branch then
      branch = arg
    end
  end

  return branch, opts
end

---Parse create command arguments
---@param args string[]
---@return string|nil branch
---@return string|nil base
---@return table opts
function M.parse_create_args(args)
  local opts = {}
  local branch = nil
  local base = nil

  for _, arg in ipairs(args) do
    if arg:match("^--base=") then
      base = arg:sub(8)
    elseif arg == "--no-verify" then
      opts.no_verify = true
    elseif not arg:match("^-") and not branch then
      branch = arg
    end
  end

  return branch, base, opts
end

---Complete function for :Worktree command
---@param arglead string
---@param cmdline string
---@param cursorpos number
---@return string[]
function M.complete(arglead, cmdline, cursorpos)
  local args = vim.split(cmdline, " ", { trimempty = true })
  table.remove(args, 1)

  if #args == 0 or (#args == 1 and arglead ~= "" and not cmdline:sub(cursorpos, cursorpos):match("%s")) then
    return complete_subcommands(arglead)
  end

  local subcmd = args[1]

  if subcmd == "switch" or subcmd == "create" or subcmd == "remove" then
    return complete_branches(arglead)
  end

  if subcmd == "hooks" then
    return complete_hooks(arglead)
  end

  return {}
end

---Execute list subcommand
local function execute_list()
  local wt = require("worktrunk")
  local worktrees = wt.list()

  if #worktrees == 0 then
    vim.notify("No worktrees found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(worktrees, {
    prompt = "Select worktree:",
    format_item = function(worktree)
      local current = wt.current()
      local marker = current and current.branch == worktree.branch and "● " or "  "
      return marker .. worktree.branch
    end,
  }, function(choice)
    if choice then
      wt.switch(choice.branch)
    end
  end)
end

---Execute switch subcommand
---@param args string[]
local function execute_switch(args)
  local wt = require("worktrunk")
  local branch, opts = M.parse_switch_args(args)

  if not branch then
    -- Interactive mode - show picker
    local worktrees = wt.list()
    vim.ui.select(worktrees, {
      prompt = "Switch to worktree:",
      format_item = function(worktree)
        return worktree.branch
      end,
    }, function(choice)
      if choice then
        wt.switch(choice.branch, opts)
      end
    end)
  else
    wt.switch(branch, opts)
  end
end

---Execute create subcommand
---@param args string[]
local function execute_create(args)
  local wt = require("worktrunk")
  local branch, base, opts = M.parse_create_args(args)

  if not branch then
    vim.ui.input({ prompt = "Branch name: " }, function(input)
      if input then
        wt.create(input, base, opts)
      end
    end)
  else
    wt.create(branch, base, opts)
  end
end

---Execute remove subcommand
---@param args string[]
local function execute_remove(args)
  local wt = require("worktrunk")
  local branch, opts = M.parse_remove_args(args)

  if not branch then
    local worktrees = wt.list()
    vim.ui.select(worktrees, {
      prompt = "Remove worktree:",
      format_item = function(worktree)
        return worktree.branch
      end,
    }, function(choice)
      if choice then
        confirm_remove(choice.branch, opts)
      end
    end)
  else
    confirm_remove(branch, opts)
  end
end

---Confirm removal of a worktree
---@param branch string
---@param opts table
function confirm_remove(branch, opts)
  local config = require("worktrunk.config").get()

  if config and config.confirm_remove and not opts.force then
    vim.ui.select({ "Yes", "No" }, {
      prompt = "Remove worktree '" .. branch .. "'?",
    }, function(choice)
      if choice == "Yes" then
        local wt = require("worktrunk")
        wt.remove(branch, opts)
      end
    end)
  else
    local wt = require("worktrunk")
    wt.remove(branch, opts)
  end
end

---Execute hooks subcommand
---@param args string[]
local function execute_hooks(args)
  local hook_type = args[1]
  if hook_type then
    local wt = require("worktrunk")
    wt.run_hook(hook_type)
  else
    vim.notify("Available hooks: pre-switch, post-create, post-switch, pre-remove, post-remove", vim.log.levels.INFO)
  end
end

---Execute current subcommand
local function execute_current()
  local wt = require("worktrunk")
  local current = wt.current()
  if current then
    print("Current: " .. current.branch .. " at " .. current.path)
  else
    print("Not in a worktree")
  end
end

---Execute a Worktree command
---@param args_str string
function M.execute(args_str)
  local args = vim.split(args_str, " ", { trimempty = true })
  local subcmd = table.remove(args, 1)

  if not subcmd or subcmd == "" then
    execute_list()
    return
  end

  local handlers = {
    list = execute_list,
    switch = execute_switch,
    create = execute_create,
    remove = execute_remove,
    hooks = execute_hooks,
    current = execute_current,
  }

  local handler = handlers[subcmd]
  if handler then
    handler(args)
  else
    vim.notify("Unknown subcommand: " .. subcmd, vim.log.levels.ERROR)
  end
end

return M
