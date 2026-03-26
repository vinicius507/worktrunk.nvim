---
name: nvim-lua-module
description: Create and structure Lua modules for Neovim configuration. Use when writing utility functions, organizing code into reusable modules, or creating library functions in lua/lib/.
---

# Neovim Lua Module Development

## When to Use

Use this skill when:

- Creating utility modules in `lua/lib/`
- Organizing configuration code into reusable components
- Writing helper functions that will be imported by multiple files
- Developing library functions for window management, table utilities, LSP helpers, etc.
- Converting inline code into maintainable, testable modules

## Module Pattern

Lua modules in Neovim follow a consistent table-based pattern:

```lua
local M = {}

---@param name string The parameter description
---@return type The return value description
function M.function_name(name)
  -- implementation
  return result
end

return M
```

## Directory Organization

Place modules in appropriate locations:

| Location | Purpose | Example |
|----------|---------|---------|
| `lua/lib/` | Utility modules | `lua/lib/tables.lua` |
| `lua/lib/` | Window helpers | `lua/lib/windows.lua` |
| `lua/lib/` | LSP utilities | `lua/lib/lsp.lua` |

Import modules using `require`:

```lua
local tables = require("lib.tables")
local windows = require("lib.windows")
```

## Workflow

### 1. Create the module file

Create a new file in `lua/lib/` with a descriptive name:

```bash
# Example: table utilities
lua/lib/tables.lua

# Example: window management
lua/lib/windows.lua
```

### 2. Define the module table

Start every module with the standard pattern:

```lua
local M = {}
```

This creates a local table that will hold all exported functions.

### 3. Add EmmyLua annotations

Document every function with proper annotations:

```lua
---@param t table Table to check
---@return boolean True if table is empty
function M.is_empty(t)
  -- implementation
end
```

### 4. Implement functions with clear signatures

Write functions with descriptive names and type hints:

```lua
function M.process(input)
  -- Clear implementation
  return result
end
```

### 5. Return the module table

Always end the file with:

```lua
return M
```

This makes all `M.*` functions available to callers.

## Code Templates

### Basic Module with Single Function

```lua
local M = {}

---@param str string Input string
---@return string Trimmed string
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

return M
```

### Module with Multiple Related Functions

```lua
local M = {}

---@param t table Table to check
---@return boolean True if table is empty
function M.is_empty(t)
  return next(t) == nil
end

---@param t table Table to count
---@return number Number of elements
function M.count(t)
  local c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  return c
end

---@param t table Table to copy
---@return table Shallow copy of table
function M.copy(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = v
  end
  return result
end

return M
```

### Module with Local Helper Functions

```lua
local M = {}

-- Private helper function (not exported)
local function normalize_path(path)
  return path:gsub("\\", "/"):gsub("//+", "/")
end

-- Private helper function (not exported)
local function get_extension(path)
  return path:match("%.([^%.]+)$")
end

---@param filepath string File path to analyze
---@return string Normalized path
function M.normalize(filepath)
  return normalize_path(filepath)
end

---@param filepath string File path
---@return string|nil File extension or nil
function M.extension(filepath)
  return get_extension(normalize_path(filepath))
end

return M
```

## Lazy Require Patterns

### Deferred Module Loading

Load modules inside functions rather than at the top level:

**Anti-pattern (eager loading):**
```lua
-- Loads at startup even if function never called
local heavy_module = require("heavy.module")

function M.do_something()
  heavy_module.action()  -- Already loaded
end
```

**Pattern (lazy loading):**
```lua
function M.do_something()
  -- Only loads when function is called
  local heavy_module = require("heavy.module")
  heavy_module.action()
end
```

### Conditional Loading with pcall

```lua
function M.safe_operation()
  local ok, module = pcall(require, "optional.module")
  if not ok then
    vim.notify("Optional module not available")
    return
  end
  module.operation()
end
```

### Cached Lazy Values

```lua
local cached_value = nil

function M.get_expensive_value()
  if not cached_value then
    cached_value = expensive_computation()
  end
  return cached_value
end
```

## Best Practices

- Use `local M = {}` at the start of every module
- Always end with `return M`
- Prefix private functions with `local` (not exported)
- Use descriptive function names
- Add EmmyLua annotations for type safety
- Keep modules focused on a single domain
- Group related functions together

## References

| Reference | Description |
|-----------|-------------|
| `:help lua-guide` | Lua programming guide |
| `:help lua-module` | Lua module patterns |
| `:help vim.api` | Neovim API functions |
