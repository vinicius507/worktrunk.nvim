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
  local subcmds = { "list", "switch", "remove", "hooks", "current", "merge", "step" }
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
    "show",
    "pre-switch",
    "post-create",
    "post-start",
    "post-switch",
    "pre-commit",
    "pre-merge",
    "post-merge",
    "pre-remove",
    "post-remove",
    "approvals",
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
  local i = 1

  while i <= #args do
    local arg = args[i]

    if arg == "--create" or arg == "-c" then
      opts.create = true
    elseif arg == "--base" or arg == "-b" then
      i = i + 1
      if i <= #args then
        opts.base = args[i]
      end
    elseif arg:match("^--base=") then
      opts.base = arg:sub(8)
    elseif arg == "--execute" or arg == "-x" then
      i = i + 1
      if i <= #args then
        opts.execute = args[i]
      end
    elseif arg:match("^--execute=") then
      opts.execute = arg:sub(11)
    elseif arg == "--clobber" then
      opts.clobber = true
    elseif arg == "--no-cd" then
      opts.no_cd = true
    elseif arg == "--branches" then
      opts.branches = true
    elseif arg == "--remotes" then
      opts.remotes = true
    elseif arg == "--yes" or arg == "-y" then
      opts.yes = true
    elseif arg == "--no-verify" then
      opts.no_verify = true
    elseif not arg:match("^-") and not branch then
      branch = arg
    end

    i = i + 1
  end

  return branch, opts
end

---Parse remove command arguments
---@param args string[]
---@return string[] branches
---@return table opts
function M.parse_remove_args(args)
  local opts = {}
  local branches = {}

  local i = 1
  while i <= #args do
    local arg = args[i]

    if arg == "--force" or arg == "-f" then
      opts.force = true
    elseif arg == "--force-delete" or arg == "-D" then
      opts.force_delete = true
    elseif arg == "--no-delete-branch" then
      opts.no_delete_branch = true
    elseif arg == "--foreground" then
      opts.foreground = true
    elseif arg == "--yes" or arg == "-y" then
      opts.yes = true
    elseif arg == "--no-verify" then
      opts.no_verify = true
    elseif not arg:match("^-") then
      table.insert(branches, arg)
    end

    i = i + 1
  end

  return branches, opts
end

---Parse list command arguments
---@param args string[]
---@return table opts
function M.parse_list_args(args)
  local opts = {}

  for _, arg in ipairs(args) do
    if arg == "--branches" then
      opts.branches = true
    elseif arg == "--remotes" then
      opts.remotes = true
    elseif arg == "--full" then
      opts.full = true
    elseif arg == "--progressive" then
      opts.progressive = true
    end
  end

  return opts
end

---Parse merge command arguments
---@param args string[]
---@return string|nil target
---@return table opts
function M.parse_merge_args(args)
  local opts = {}
  local target = nil

  for _, arg in ipairs(args) do
    if arg == "--no-squash" then
      opts.no_squash = true
    elseif arg == "--no-commit" then
      opts.no_commit = true
    elseif arg == "--no-rebase" then
      opts.no_rebase = true
    elseif arg == "--no-remove" then
      opts.no_remove = true
    elseif arg == "--no-ff" then
      opts.no_ff = true
    elseif arg:match("^--stage=") then
      opts.stage = arg:sub(9)
    elseif arg == "--yes" or arg == "-y" then
      opts.yes = true
    elseif arg == "--no-verify" then
      opts.no_verify = true
    elseif not arg:match("^-") and not target then
      target = arg
    end
  end

  return target, opts
end

---Parse step command arguments
---@param args string[]
---@return string|nil subcommand
---@return table opts
function M.parse_step_args(args)
  local opts = {}
  local subcommand = nil

  for _, arg in ipairs(args) do
    if arg:match("^--stage=") then
      opts.stage = arg:sub(9)
    elseif not arg:match("^-") and not subcommand then
      subcommand = arg
    end
  end

  return subcommand, opts
end

---Complete switch flags
---@param arglead string
---@return string[]
local function complete_switch_flags(arglead)
  local flags = {
    "-c",
    "--create",
    "-b",
    "--base=",
    "-x",
    "--execute=",
    "--clobber",
    "--no-cd",
    "--branches",
    "--remotes",
    "-y",
    "--yes",
    "--no-verify",
  }
  return vim.tbl_filter(function(flag)
    return vim.startswith(flag, arglead)
  end, flags)
end

---Complete merge flags
---@param arglead string
---@return string[]
local function complete_merge_flags(arglead)
  local flags = {
    "--no-squash",
    "--no-commit",
    "--no-rebase",
    "--no-remove",
    "--no-ff",
    "--stage=all",
    "--stage=tracked",
    "--stage=none",
    "-y",
    "--yes",
    "--no-verify",
  }
  return vim.tbl_filter(function(flag)
    return vim.startswith(flag, arglead)
  end, flags)
end

---Complete step subcommands
---@param arglead string
---@return string[]
local function complete_step_subcommands(arglead)
  local subcmds = { "commit", "squash", "rebase", "push", "diff", "copy-ignored" }
  return vim.tbl_filter(function(cmd)
    return vim.startswith(cmd, arglead)
  end, subcmds)
end

---Complete remove flags
---@param arglead string
---@return string[]
local function complete_remove_flags(arglead)
  local flags = {
    "-f",
    "--force",
    "-D",
    "--force-delete",
    "--no-delete-branch",
    "--foreground",
    "-y",
    "--yes",
    "--no-verify",
  }
  return vim.tbl_filter(function(flag)
    return vim.startswith(flag, arglead)
  end, flags)
end

---Complete list flags
---@param arglead string
---@return string[]
local function complete_list_flags(arglead)
  local flags = {
    "--branches",
    "--remotes",
    "--full",
    "--progressive",
  }
  return vim.tbl_filter(function(flag)
    return vim.startswith(flag, arglead)
  end, flags)
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

  -- Remove subcommand from args for further parsing
  table.remove(args, 1)

  if subcmd == "switch" then
    -- Check if completing a flag or branch
    if arglead:match("^%-") then
      return complete_switch_flags(arglead)
    end
    return complete_branches(arglead)
  end

  if subcmd == "remove" then
    if arglead:match("^%-") then
      return complete_remove_flags(arglead)
    end
    return complete_branches(arglead)
  end

  if subcmd == "merge" then
    if arglead:match("^%-") then
      return complete_merge_flags(arglead)
    end
    return complete_branches(arglead)
  end

  if subcmd == "list" then
    return complete_list_flags(arglead)
  end

  if subcmd == "step" then
    return complete_step_subcommands(arglead)
  end

  if subcmd == "hooks" then
    return complete_hooks(arglead)
  end

  return {}
end

---Execute list subcommand
---@param args string[]
local function execute_list(args)
  local wt = require("worktrunk")
  local opts = M.parse_list_args(args)
  local worktrees = wt.list(opts)

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

---Execute remove subcommand
---@param args string[]
local function execute_remove(args)
  local wt = require("worktrunk")
  local branches, opts = M.parse_remove_args(args)

  if #branches == 0 then
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
    for _, branch in ipairs(branches) do
      confirm_remove(branch, opts)
    end
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
  local wt = require("worktrunk")

  if not hook_type then
    vim.notify(
      "Available hooks: show, pre-switch, post-create, post-start, post-switch, pre-commit, pre-merge, post-merge, pre-remove, post-remove, approvals",
      vim.log.levels.INFO
    )
    return
  end

  local valid_hooks = {
    show = true,
    ["pre-switch"] = true,
    ["post-create"] = true,
    ["post-start"] = true,
    ["post-switch"] = true,
    ["pre-commit"] = true,
    ["pre-merge"] = true,
    ["post-merge"] = true,
    ["pre-remove"] = true,
    ["post-remove"] = true,
    approvals = true,
  }

  if valid_hooks[hook_type] then
    wt.run_hook(hook_type)
  else
    vim.notify("Unknown hook type: " .. hook_type, vim.log.levels.ERROR)
  end
end

---Execute merge subcommand
---@param args string[]
local function execute_merge(args)
  local wt = require("worktrunk")
  local target, opts = M.parse_merge_args(args)

  wt.merge(target, opts)
end

---Execute step subcommand
---@param args string[]
local function execute_step(args)
  local wt = require("worktrunk")
  local subcommand, opts = M.parse_step_args(args)

  if not subcommand then
    vim.notify("Available step commands: commit, squash, rebase, push, diff, copy-ignored", vim.log.levels.INFO)
    return
  end

  wt.step(subcommand, opts)
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
    execute_list(args)
    return
  end

  local handlers = {
    list = execute_list,
    switch = execute_switch,
    remove = execute_remove,
    hooks = execute_hooks,
    current = execute_current,
    merge = execute_merge,
    step = execute_step,
  }

  local handler = handlers[subcmd]
  if handler then
    handler(args)
  else
    vim.notify("Unknown subcommand: " .. subcmd, vim.log.levels.ERROR)
  end
end

return M
