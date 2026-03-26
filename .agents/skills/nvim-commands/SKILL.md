---
name: nvim-commands
description: Create scoped user commands with subcommand completions for Neovim plugins. Use when creating :Commands with subcommands, implementing tab completion for custom commands, or avoiding command namespace pollution. Essential for plugin commands with multiple operations.
---

# nvim-commands Skill

Guide for creating scoped user commands with subcommand support and intelligent tab completion in Neovim plugins.

## When to Use

Create a scoped command when your Neovim plugin needs:

- **Multiple related operations** under a single command namespace (e.g., `:MyPlugin list`, `:MyPlugin switch`, `:MyPlugin remove`)
- **Tab completion** for subcommands, flags, and dynamic values (branches, files, etc.)
- **Avoid command pollution** by grouping operations instead of creating `:MyPluginList`, `:MyPluginSwitch`, etc.
- **Complex argument parsing** with flags like `--create`, `-c`, `--base=value`
- **Special shortcuts** like `^`, `-`, `@`, `pr:N`, `mr:N`

## Workflow

1. **Define the subcommand table** with `impl` and `complete` functions for each operation
2. **Create argument parsing functions** to handle flags and positional arguments
3. **Implement completion functions** for subcommands, flags, and dynamic values
4. **Register the user command** using `vim.api.nvim_create_user_command()` with `complete` handler
5. **Route completions** based on command context (subcommand vs flags vs values)

## Code Templates

### 1. Basic Subcommand Table Structure

```lua
---@module "myplugin.commands"
local M = {}

---@class myplugin.Subcommand
---@field impl fun(args: string[], opts: table)
---@field complete fun(arglead: string, cmdline: string, cursorpos: number): string[]

---@type table<string, myplugin.Subcommand>
M.subcommands = {}

-- List subcommand
M.subcommands.list = {
  impl = function(args, _)
    local opts = parse_list_args(args)
    -- Implementation here
    print("Listing with opts:", vim.inspect(opts))
  end,
  complete = function(arglead, _, _)
    return complete_list_flags(arglead)
  end,
}

-- Switch subcommand with dynamic completion
M.subcommands.switch = {
  impl = function(args, _)
    local target, opts = parse_switch_args(args)
    if not target then
      print("No target specified")
      return
    end
    -- Implementation here
    print("Switching to:", target)
  end,
  complete = function(arglead, cmdline, cursorpos)
    local args = vim.split(cmdline, " ", { trimempty = true })
    table.remove(args, 1) -- Remove command name

    if arglead:match("^%-%-") then
      return complete_switch_flags(arglead)
    end
    return complete_targets(arglead)
  end,
}

return M
```

### 2. Completion Function for Flags

```lua
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
```

### 3. Completion Function for Dynamic Values

```lua
---Get dynamic values from external source
---@return string[]
local function get_dynamic_values()
  local api = require("myplugin.api")
  local ok, result = api.fetch_items()
  if not ok then
    return {}
  end

  return vim.tbl_map(function(item)
    return item.name
  end, result)
end

---Complete dynamic values (e.g., branches, items)
---@param arglead string
---@return string[]
local function complete_targets(arglead)
  local items = get_dynamic_values()
  return vim.tbl_filter(function(item)
    return vim.startswith(item, arglead)
  end, items)
end

---Complete subcommands
---@param arglead string
---@return string[]
local function complete_subcommands(arglead)
  local subcmds = { "list", "switch", "remove", "status" }
  return vim.tbl_filter(function(cmd)
    return vim.startswith(cmd, arglead)
  end, subcmds)
end
```

### 4. Argument Parsing Function

```lua
---Parse switch command arguments
---Handles: --flag, -f, --key=value, positional args, special shortcuts
---@param args string[]
---@return string|nil target
---@return table opts
local function parse_switch_args(args)
  local opts = {}
  local target = nil
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
      -- Handle --base=value syntax
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
    elseif arg == "-" or arg == "@" or arg:match("^pr:%d+") or arg:match("^mr:%d+") then
      -- Special shortcuts for targets
      target = arg
    elseif not arg:match("^-") and not target then
      -- First non-flag argument is the target
      target = arg
    end

    i = i + 1
  end

  return target, opts
end

---Parse simple flag arguments
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
```

### 5. vim.api.nvim_create_user_command Setup

```lua
-- plugin/myplugin.lua
-- This file is sourced when Neovim starts

vim.api.nvim_create_user_command("MyPlugin", function(opts)
  -- Lazy-load the module and ensure initialization
  require("myplugin")._ensure_initialized()
  require("myplugin.commands").execute(opts.args)
end, {
  nargs = "*",  -- Accept any number of arguments
  complete = function(arglead, cmdline, cursorpos)
    require("myplugin")._ensure_initialized()
    return require("myplugin.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "MyPlugin management commands",
})

-- Optional: Define <Plug> mappings for common operations
vim.keymap.set("n", "<Plug>(MyPluginList)", function()
  require("myplugin")._ensure_initialized()
  require("myplugin.commands").execute("list")
end, { silent = true })

vim.keymap.set("n", "<Plug>(MyPluginSwitch)", function()
  require("myplugin")._ensure_initialized()
  require("myplugin.commands").execute("switch")
end, { silent = true })
```

### 6. Complete Function Routing

```lua
---Execute a command with subcommand routing
---@param args_str string
function M.execute(args_str)
  local args = vim.split(args_str, " ", { trimempty = true })
  local subcmd_name = table.remove(args, 1) or "list"  -- Default subcommand

  local subcmd = M.subcommands[subcmd_name]
  if subcmd then
    subcmd.impl(args, {})
  else
    require("myplugin.ui.notify").error("Unknown subcommand: " .. subcmd_name)
  end
end

---Complete function for :MyPlugin command
---Routes to appropriate subcommand's complete function
---@param arglead string
---@param cmdline string
---@param cursorpos number
---@return string[]
function M.complete(arglead, cmdline, cursorpos)
  local args = vim.split(cmdline, " ", { trimempty = true })
  table.remove(args, 1)  -- Remove command name

  -- If no args or completing the first argument, complete subcommands
  if #args == 0 or (#args == 1 and arglead ~= "" and not cmdline:sub(cursorpos, cursorpos):match("%s")) then
    return complete_subcommands(arglead)
  end

  -- Route to subcommand's completion function
  local subcmd_name = args[1]
  local subcmd = M.subcommands[subcmd_name]

  if subcmd then
    table.remove(args, 1)  -- Remove subcommand name
    return subcmd.complete(arglead, cmdline, cursorpos)
  end

  return {}
end

return M
```

## Common Patterns

### Pattern: Subcommand with Both Flags and Positional Args

```lua
M.subcommands.switch = {
  impl = function(args, _)
    local target, opts = parse_switch_args(args)

    if not target then
      -- Interactive mode
      show_picker_and_switch(opts)
    else
      -- Direct target specified
      perform_switch(target, opts)
    end
  end,
  complete = function(arglead, cmdline, cursorpos)
    local args = vim.split(cmdline, " ", { trimempty = true })
    table.remove(args, 1)

    -- Complete flags if arglead starts with -
    if arglead:match("^%-%-") then
      return complete_switch_flags(arglead)
    end

    -- Complete dynamic values otherwise
    return complete_targets(arglead)
  end,
}
```

### Pattern: Boolean vs Value Flags

```lua
-- Boolean flag (no value)
if arg == "--force" or arg == "-f" then
  opts.force = true

-- Flag with next-arg value
elseif arg == "--base" or arg == "-b" then
  i = i + 1
  if i <= #args then
    opts.base = args[i]
  end

-- Flag with inline value
elseif arg:match("^--base=") then
  opts.base = arg:sub(8)  -- Extract after "--base="
end
```

### Pattern: Filtering Completions

```lua
-- Filter completions based on arglead prefix
return vim.tbl_filter(function(item)
  return vim.startswith(item, arglead)
end, all_items)

-- Alternative: case-insensitive matching
return vim.tbl_filter(function(item)
  return vim.startswith(item:lower(), arglead:lower())
end, all_items)
```

### Pattern: Detecting Completion Context

```lua
function M.complete(arglead, cmdline, cursorpos)
  local args = vim.split(cmdline, " ", { trimempty = true })
  table.remove(args, 1)

  -- Check if we're completing the first argument
  local is_first_arg = #args == 0 or
    (#args == 1 and
     arglead ~= "" and
     not cmdline:sub(cursorpos, cursorpos):match("%s"))

  if is_first_arg then
    return complete_subcommands(arglead)
  end

  -- ... route to subcommand
end
```

## Key Points

- **Lazy loading**: Always wrap require() calls in functions, not at module load time, to avoid slowing down Neovim startup
- **Default subcommand**: Set a sensible default (e.g., "list") when no subcommand is provided
- **Error handling**: Provide clear error messages for unknown subcommands
- **Case sensitivity**: Decide early if your command names are case-sensitive (recommend: lowercase only)
- **Flag consistency**: Use common conventions like `-f` / `--force`, `-y` / `--yes`, `--no-*` for negation
- **Completion order**: Complete subcommands first, then flags, then dynamic values
- **Special characters**: Handle shortcuts like `@`, `-`, `^` explicitly in your parser
- **Nvim 0.9+**: Use `vim.split()` with `trimempty = true` for reliable argument parsing

## References

- `:help nvim_create_user_command()` - User command API
- `:help command-completion` - Completion options
- `:help vim.split()` - String splitting utility
- `:help vim.tbl_filter()` - Table filtering utility
- `:help vim.startswith()` - String prefix check
- [worktrunk.nvim lua/worktrunk/commands/init.lua](lua/worktrunk/commands/init.lua) - Full implementation example
- [worktrunk.nvim plugin/worktrunk.lua](plugin/worktrunk.lua) - Command registration example
