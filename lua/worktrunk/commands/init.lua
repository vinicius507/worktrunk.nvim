---@module "worktrunk.commands"
---Commands module with subcommand table pattern

local M = {}

-- Local notify module reference for consistent notifications
local notify = require("worktrunk.ui.notify")

---@class worktrunk.Subcommand
---@field impl fun(args: string[], opts: table)
---@field complete fun(arglead: string, cmdline: string, cursorpos: number): string[]

-- Forward declarations
local cmd_list, cmd_switch, cmd_remove, cmd_hooks, cmd_current, cmd_merge, cmd_step

---Get all worktree branches for completion
---@return string[]
local function get_branches()
  local api = require("worktrunk.api.cli")
  local ok, result = api.list()
  if not ok then
    return {}
  end

  return vim.tbl_map(function(w)
    return w.branch
  end, result)
end

---Parse switch command arguments
---@param args string[]
---@return string|nil branch
---@return table opts
local function parse_switch_args(args)
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
    elseif arg == "-" or arg == "@" or arg:match("^pr:%d+") or arg:match("^mr:%d+") then
      -- Special shortcuts for branches
      branch = arg
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
local function parse_remove_args(args)
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
local function parse_list_args(args)
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
local function parse_merge_args(args)
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
local function parse_step_args(args)
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

-- Define subcommands table
---@type table<string, worktrunk.Subcommand>
M.subcommands = {}

-- List subcommand
M.subcommands.list = {
  impl = function(args, _)
    local opts = parse_list_args(args)
    local api = require("worktrunk.api.cli")
    local picker = require("worktrunk.ui.picker")

    local ok, result = api.list(opts)
    if not ok then
      notify.error("Failed to list worktrees: " .. tostring(result))
      return
    end

    local worktrees = result
    if #worktrees == 0 then
      notify.warn("No worktrees found")
      return
    end

    picker.worktrees(worktrees, {
      prompt = "Select worktree:",
    }, function(choice)
      if choice then
        local switch_ok, switch_err = api.switch(choice.branch)
        if not switch_ok then
          notify.error("Failed to switch: " .. tostring(switch_err))
        end
      end
    end)
  end,
  complete = function(arglead, _, _)
    return complete_list_flags(arglead)
  end,
}

-- Switch subcommand
M.subcommands.switch = {
  impl = function(args, _)
    local branch, opts = parse_switch_args(args)
    local api = require("worktrunk.api.cli")
    local picker = require("worktrunk.ui.picker")

    if not branch then
      -- Interactive mode - show picker
      local ok, result = api.list()
      if not ok then
        notify.error("Failed to list worktrees: " .. tostring(result))
        return
      end

      picker.worktrees(result, {
        prompt = "Switch to worktree:",
      }, function(choice)
        if choice then
          local switch_ok, switch_err = api.switch(choice.branch, opts)
          if not switch_ok then
            notify.error("Failed to switch: " .. tostring(switch_err))
          else
            if opts.create then
              notify.success("Created worktree '" .. choice.branch .. "'")
            else
              notify.success("Switched to worktree '" .. choice.branch .. "'")
            end
          end
        end
      end)
    else
      local ok, err = api.switch(branch, opts)
      if not ok then
        notify.error("Failed to switch: " .. tostring(err))
      else
        if opts.create then
          notify.success("Created worktree '" .. branch .. "'")
        else
          notify.success("Switched to worktree '" .. branch .. "'")
        end
      end
    end
  end,
  complete = function(arglead, cmdline, cursorpos)
    local args = vim.split(cmdline, " ", { trimempty = true })
    table.remove(args, 1)

    if arglead:match("^%-%-") then
      return complete_switch_flags(arglead)
    end
    return complete_branches(arglead)
  end,
}

-- Remove subcommand
M.subcommands.remove = {
  impl = function(args, _)
    local branches, opts = parse_remove_args(args)
    local api = require("worktrunk.api.cli")
    local notify = require("worktrunk.ui.notify")
    local picker = require("worktrunk.ui.picker")
    local config = require("worktrunk.config.internal").get()

    local function confirm_remove(branch)
      local function do_remove()
        local ok, err = api.remove(branch, opts)
        if ok then
          notify.success("Removed worktree " .. branch)
        else
          notify.error("Failed to remove: " .. tostring(err))
        end
      end

      if config.confirm_remove and not opts.force then
        picker.confirm("Remove worktree '" .. branch .. "'?", function(confirmed)
          if confirmed then
            do_remove()
          end
        end)
      else
        do_remove()
      end
    end

    if #branches == 0 then
      local ok, result = api.list()
      if not ok then
        notify.error("Failed to list worktrees: " .. tostring(result))
        return
      end

      picker.worktrees(result, {
        prompt = "Remove worktree:",
      }, function(choice)
        if choice then
          confirm_remove(choice.branch)
        end
      end)
    else
      for _, branch in ipairs(branches) do
        confirm_remove(branch)
      end
    end
  end,
  complete = function(arglead, _, _)
    if arglead:match("^%-%-") then
      return complete_remove_flags(arglead)
    end
    return complete_branches(arglead)
  end,
}

-- Hooks subcommand
M.subcommands.hooks = {
  impl = function(args, _)
    local hook_type = args[1]

    if not hook_type then
      notify.echo(
        "Available hooks: show, pre-switch, post-create, post-start, post-switch, pre-commit, pre-merge, post-merge, pre-remove, post-remove, approvals"
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
      notify.success("Running hook: " .. hook_type)
    else
      notify.error("Unknown hook type: " .. hook_type)
    end
  end,
  complete = function(arglead, _, _)
    return complete_hooks(arglead)
  end,
}

-- Current subcommand
M.subcommands.current = {
  impl = function(_, _)
    local api = require("worktrunk.api.cli")

    local ok, result = api.current()
    if not ok then
      notify.error("Failed to get current worktree: " .. tostring(result))
      return
    end

    if result then
      notify.echo("Current: " .. result.branch .. " at " .. result.path)
    else
      notify.warn("Not in a worktree")
    end
  end,
  complete = function(_, _, _)
    return {}
  end,
}

-- Merge subcommand
M.subcommands.merge = {
  impl = function(args, _)
    local target, opts = parse_merge_args(args)
    local api = require("worktrunk.api.cli")

    local ok, err = api.merge(target, opts)
    if not ok then
      notify.error("Failed to merge: " .. tostring(err))
    else
      notify.success("Merged successfully")
    end
  end,
  complete = function(arglead, _, _)
    if arglead:match("^%-%-") then
      return complete_list_flags(arglead)
    end
    return complete_branches(arglead)
  end,
}

-- Step subcommand
M.subcommands.step = {
  impl = function(args, _)
    local subcommand, opts = parse_step_args(args)
    local api = require("worktrunk.api.cli")
    local notify = require("worktrunk.ui.notify")

    if not subcommand then
      notify.echo("Available step commands: commit, squash, rebase, push, diff, copy-ignored")
      return
    end

    local ok, err = api.step(subcommand, opts)
    if not ok then
      notify.error("Failed to run step: " .. tostring(err))
    else
      notify.success("Step '" .. subcommand .. "' completed")
    end
  end,
  complete = function(arglead, _, _)
    return complete_step_subcommands(arglead)
  end,
}

---Execute a Worktree command
---@param args_str string
function M.execute(args_str)
  local args = vim.split(args_str, " ", { trimempty = true })
  local subcmd_name = table.remove(args, 1) or "list"

  local subcmd = M.subcommands[subcmd_name]
  if subcmd then
    subcmd.impl(args, {})
  else
    require("worktrunk.ui.notify").error("Unknown subcommand: " .. subcmd_name)
  end
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

  local subcmd_name = args[1]
  local subcmd = M.subcommands[subcmd_name]

  if subcmd then
    table.remove(args, 1)
    return subcmd.complete(arglead, cmdline, cursorpos)
  end

  return {}
end

return M
