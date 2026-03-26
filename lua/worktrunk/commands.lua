---@module "worktrunk.commands"
---Backward compatibility shim - delegates to commands/init.lua
---DEPRECATED: Use require("worktrunk.commands") (which loads init.lua) directly

local new_commands = require("worktrunk.commands.init")
local M = {}

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

---Complete function for :Worktree command
---@param arglead string
---@param cmdline string
---@param cursorpos number
---@return string[]
function M.complete(arglead, cmdline, cursorpos)
  return new_commands.complete(arglead, cmdline, cursorpos)
end

---Execute a Worktree command
---@param args_str string
function M.execute(args_str)
  return new_commands.execute(args_str)
end

return M
