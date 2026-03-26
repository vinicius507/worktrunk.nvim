---
name: nvim-health
description: Implement health checks for Neovim plugins using vim.health. Use when creating checkhealth integrations, validating dependencies, checking configuration, or troubleshooting plugin issues. Provides :checkhealth integration for user diagnostics.
---

# nvim-health

Guide for implementing health checks for Neovim plugins using vim.health. Provides user diagnostics via `:checkhealth` command.

## When to Use

- Creating a new Neovim plugin and need to add health checks
- Adding `:checkhealth` integration to an existing plugin
- Validating plugin dependencies (required or optional)
- Checking configuration for errors or typos
- Reporting plugin status and version information
- Troubleshooting user issues with your plugin

## Health Check Structure

A typical health check implementation consists of:

1. **Main entry point** (`M.check()`) - Called by `:checkhealth`
2. **vim.health.start()** - Begins a section
3. **Check functions** - Organized into logical groups (CLI, config, optional deps)
4. **Report functions** - ok(), warn(), error(), info() for results

## Workflow

### 1. Create lua/<plugin>/health.lua

```lua
---@module "myplugin.health"
local M = {}

function M.check()
  vim.health.start("myplugin.nvim")
  -- Run all checks
end

return M
```

### 2. Organize checks into sections

```lua
function M.check()
  vim.health.start("myplugin.nvim")
  
  M._check_required_deps()
  M._check_config()
  M._check_optional_deps()
end
```

### 3. Implement each check

Use appropriate vim.health functions based on check results:

- `vim.health.ok(msg)` - Check passed
- `vim.health.warn(msg, suggestions)` - Check passed but with concerns
- `vim.health.error(msg, solutions)` - Critical issue
- `vim.health.info(msg)` - Informational message

### 4. User runs :checkhealth

```vim
:checkhealth myplugin
```

## Code Templates

### Template 1: Basic Health File Structure

```lua
---@module "myplugin.health"
local M = {}

function M.check()
  vim.health.start("myplugin.nvim")

  -- Check required CLI/binary
  M._check_cli()

  -- Check configuration
  M._check_config()

  -- Check optional features
  M._check_optional_deps()
end

function M._check_cli()
  -- Implementation
end

function M._check_config()
  -- Implementation
end

function M._check_optional_deps()
  -- Implementation
end

return M
```

### Template 2: Dependency Checking

```lua
function M._check_cli()
  -- Check if command is available
  if vim.fn.executable("mycommand") == 0 then
    vim.health.error(
      "mycommand not found in PATH",
      { "Install mycommand: https://example.com/install" }
    )
    return
  end

  vim.health.ok("mycommand found in PATH")
end
```

### Template 3: Version Validation

```lua
function M._check_version()
  if vim.fn.executable("mycommand") == 0 then
    vim.health.error("mycommand not found")
    return
  end

  -- Run command to get version
  local result = vim.system({ "mycommand", "--version" }):wait()
  
  if result.code ~= 0 then
    vim.health.warn(
      "mycommand found but version check failed",
      { "Ensure mycommand is properly installed" }
    )
    return
  end

  -- Clean up output (remove trailing whitespace/newlines)
  local version = result.stdout:gsub("%s+$", "")
  vim.health.ok("mycommand found: " .. version)
end
```

### Template 4: Config Validation (Unknown Fields)

```lua
function M._check_config()
  -- Safely load config with pcall
  local ok, config = pcall(require, "myplugin.config")
  if not ok then
    vim.health.warn("Configuration module not loaded (will use defaults)")
    return
  end

  local cfg = config.get and config.get() or config
  if not cfg then
    vim.health.warn("Configuration not initialized (will use defaults)")
    return
  end

  vim.health.ok("Configuration loaded")

  -- Define known/valid configuration fields
  local known_fields = {
    "option1",
    "option2",
    "nested",
    "timeout",
  }

  -- Find unknown fields (likely typos)
  local unknown_fields = {}
  for k, _ in pairs(cfg) do
    if not vim.tbl_contains(known_fields, k) then
      table.insert(unknown_fields, k)
    end
  end

  if #unknown_fields > 0 then
    vim.health.warn(
      "Unknown configuration fields (possible typos): " .. table.concat(unknown_fields, ", "),
      { "Check documentation for valid configuration options" }
    )
  end
end
```

### Template 5: Optional Dependency Checking

```lua
function M._check_optional_deps()
  -- Check for GitHub CLI (optional PR support)
  if vim.fn.executable("gh") == 1 then
    vim.health.ok("GitHub CLI (gh) found - PR integration available")
  else
    vim.health.info("GitHub CLI (gh) not found - PR features unavailable")
  end

  -- Check for GitLab CLI (optional MR support)
  if vim.fn.executable("glab") == 1 then
    vim.health.ok("GitLab CLI (glab) found - MR integration available")
  else
    vim.health.info("GitLab CLI (glab) not found - MR features unavailable")
  end

  -- Check for optional Neovim plugin
  local has_telescope, _ = pcall(require, "telescope")
  if has_telescope then
    vim.health.ok("telescope.nvim found - picker integration available")
  else
    vim.health.info("telescope.nvim not found - using fallback picker")
  end
end
```

### Template 6: Complete Health Check Example

```lua
---@module "worktrunk.health"
local M = {}

function M.check()
  vim.health.start("worktrunk.nvim")

  M._check_cli()
  M._check_config()
  M._check_optional_deps()
end

function M._check_cli()
  if vim.fn.executable("wt") == 0 then
    vim.health.error("worktrunk CLI (wt) not found in PATH", { "Install from: https://worktrunk.dev" })
    return
  end

  local result = vim.system({ "wt", "--version" }):wait()
  if result.code ~= 0 then
    vim.health.warn("worktrunk CLI found but version check failed", { "Ensure wt is properly installed" })
    return
  end

  local version = result.stdout:gsub("%s+$", "")
  vim.health.ok("worktrunk CLI found: " .. version)
end

function M._check_config()
  local ok, config = pcall(require, "worktrunk.config.internal")
  if not ok then
    vim.health.warn("Configuration module not loaded (will use defaults)")
    return
  end

  local cfg = config.get()
  if not cfg then
    vim.health.warn("Configuration not initialized (will use defaults)")
    return
  end

  vim.health.ok("Configuration loaded")

  local known_fields = { "wt_cmd", "auto_cd", "confirm_remove", "enable_events", "ui", "hooks", "pr" }
  local unknown_fields = {}
  for k, _ in pairs(cfg) do
    if not vim.tbl_contains(known_fields, k) then
      table.insert(unknown_fields, k)
    end
  end

  if #unknown_fields > 0 then
    vim.health.warn(
      "Unknown configuration fields (possible typos): " .. table.concat(unknown_fields, ", "),
      { "Check documentation for valid configuration options" }
    )
  end
end

function M._check_optional_deps()
  if vim.fn.executable("gh") == 1 then
    vim.health.ok("GitHub CLI (gh) found - PR shortcuts available")
  else
    vim.health.info("GitHub CLI (gh) not found - PR shortcuts will not work")
  end

  if vim.fn.executable("glab") == 1 then
    vim.health.ok("GitLab CLI (glab) found - MR shortcuts available")
  else
    vim.health.info("GitLab CLI (glab) not found - MR shortcuts will not work")
  end
end

return M
```

## Validation Patterns

### Pattern: Check Executable Binary

```lua
if vim.fn.executable("command") == 0 then
  vim.health.error("command not found")
else
  vim.health.ok("command found")
end
```

### Pattern: Safe Require with pcall

```lua
local ok, module = pcall(require, "module.name")
if not ok then
  vim.health.warn("Module not available")
  return
end
```

### Pattern: Run External Command

```lua
local result = vim.system({ "command", "arg" }):wait()
if result.code ~= 0 then
  vim.health.warn("Command failed: " .. (result.stderr or "unknown error"))
else
  vim.health.ok("Success: " .. result.stdout:gsub("%s+$", ""))
end
```

### Pattern: Table Contains Check

```lua
if vim.tbl_contains(known_fields, key) then
  -- valid
else
  -- unknown field
end
```

### Pattern: String Trimming

```lua
local cleaned = output:gsub("%s+$", "")  -- Remove trailing whitespace
```

## Key Points

- **Always use pcall** when requiring modules to handle missing dependencies gracefully
- **Use vim.fn.executable()** to check if CLI tools are available (returns 0 or 1)
- **Use vim.system()** for running external commands (Neovim 0.10+)
- **Provide actionable suggestions** in warn/error messages (array of strings)
- **Differentiate required vs optional** deps using error() vs info()
- **Check for typos** in user config by validating against known fields
- **Call vim.health.start()** once at the beginning of M.check()
- **Organize checks** into logical sections for clarity
- **Handle async results** with :wait() when using vim.system()

## vim.health API Reference

| Function | Purpose | Use Case |
|----------|---------|----------|
| `vim.health.start(name)` | Begin a section | Call once in M.check() |
| `vim.health.ok(msg)` | Success report | Dependency found, config valid |
| `vim.health.warn(msg, suggestions?)` | Warning with advice | Non-critical issues, version mismatch |
| `vim.health.error(msg, solutions?)` | Critical error | Missing required dependency |
| `vim.health.info(msg)` | Informational | Optional features unavailable |

## References

- `:help vim.health` - Official Neovim documentation
- `lua/worktrunk/health.lua` - Complete working example from worktrunk.nvim
- Neovim version 0.10+ required for vim.system()
