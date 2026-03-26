---
name: nvim-config
description: Configure Neovim plugins with proper architecture separating user options from internal state. Use when creating setup() functions, implementing vim.g configuration support, or structuring plugin config with type safety. Follows meta/internal split pattern for optional vs guaranteed values.
---

# Neovim Configuration Architecture

This skill guides you through implementing a robust, type-safe configuration system for Neovim plugins that properly separates user-facing options from internal runtime state.

## When to Use

- Creating a new Neovim plugin that needs configuration
- Adding type-safe configuration to an existing plugin
- Implementing `vim.g` auto-configuration support
- Setting up lazy initialization patterns
- Enabling testable configuration (reset capability)
- Separating optional user types from guaranteed internal types

## Config Architecture

The meta/internal split pattern provides type safety at different stages:

**Meta Types (`config/meta.lua`)**:
- Define what users *can* provide
- All fields are optional with `|nil` suffix
- Used for function parameters accepting partial config

**Internal Types (`config/internal.lua`)**:
- Define what the plugin *always has*
- No optional types (guaranteed values)
- Used after merging defaults with user options

This separation ensures:
1. Users can pass partial configuration
2. Internal code never deals with nil checks for config values
3. Type checking catches missing required values
4. Clear distinction between input and runtime state

## Workflow

1. **Define Meta Types** - Create `lua/yourplugin/config/meta.lua` with optional types
2. **Define Internal Types** - Create `lua/yourplugin/config/internal.lua` with guaranteed types
3. **Setup Defaults** - Define complete default configuration table
4. **Implement vim.g Support** - Check `vim.g.yourplugin` before merging
5. **Lazy Initialization** - Auto-call setup() in get() if not initialized
6. **Add Reset Function** - Enable testing by allowing config reset
7. **Wire Up Plugin** - Call internal setup() from main init.lua setup()

## Code Templates

### Template 1: Meta Config (Optional Types)

```lua
---@module "yourplugin.config.meta"
---Type definitions for user-facing configuration

---@class yourplugin.UIConfigMeta
---@field picker_width number|nil
---@field show_preview boolean|nil
---@field theme string|nil

---@class yourplugin.HooksConfigMeta
---@field async boolean|nil
---@field timeout number|nil

---@class yourplugin.ConfigMeta
---@field enabled boolean|nil
---@field debug boolean|nil
---@field ui yourplugin.UIConfigMeta|nil
---@field hooks yourplugin.HooksConfigMeta|nil

local M = {}

return M
```

### Template 2: Internal Config (Guaranteed Types)

```lua
---@module "yourplugin.config.internal"
---Internal configuration with guaranteed values

---@class yourplugin.UIConfig
---@field picker_width number
---@field show_preview boolean
---@field theme string

---@class yourplugin.HooksConfig
---@field async boolean
---@field timeout number

---@class yourplugin.Config
---@field enabled boolean
---@field debug boolean
---@field ui yourplugin.UIConfig
---@field hooks yourplugin.HooksConfig

local M = {}

---@type yourplugin.Config|nil
local config = nil

---Default configuration values
---@type yourplugin.Config
M.defaults = {
  enabled = true,
  debug = false,
  ui = {
    picker_width = 60,
    show_preview = true,
    theme = "default",
  },
  hooks = {
    async = true,
    timeout = 0,
  },
}

---Deep merge tables
---@param t1 table
---@param t2 table
---@return table
local function merge(t1, t2)
  return vim.tbl_deep_extend("force", t1, t2)
end

---Setup the configuration
---@param opts yourplugin.ConfigMeta|nil
function M.setup(opts)
  if config then
    return
  end

  opts = opts or {}

  -- Support vim.g.yourplugin configuration
  if vim.g.yourplugin then
    opts = merge(opts, vim.g.yourplugin)
  end

  config = merge(M.defaults, opts)
end

---Get the current configuration
---@return yourplugin.Config
function M.get()
  if not config then
    M.setup()
  end
  return config
end

---Reset configuration (for testing)
function M.reset()
  config = nil
end

return M
```

### Template 3: vim.g Integration Pattern

```lua
-- In internal.lua, inside M.setup():
function M.setup(opts)
  if config then
    return
  end

  opts = opts or {}

  -- Support vim.g.yourplugin configuration
  -- Users can set: vim.g.yourplugin = { debug = true }
  if vim.g.yourplugin then
    opts = merge(opts, vim.g.yourplugin)
  end

  config = merge(M.defaults, opts)
end
```

### Template 4: Lazy Initialization in get()

```lua
---Get the current configuration
---@return yourplugin.Config
function M.get()
  if not config then
    M.setup()  -- Auto-initialize with defaults
  end
  return config
end
```

### Template 5: Reset Function for Testing

```lua
---Reset configuration (for testing)
function M.reset()
  config = nil
end
```

### Template 6: Complete Plugin Initialization Pattern

```lua
---@module "yourplugin"
---Main module for yourplugin.nvim - Public API

local M = {}

---Plugin initialized state
---@type boolean
local initialized = false

---Ensure plugin is initialized (lazy initialization)
---This function is called automatically when needed
---@return boolean
function M._ensure_initialized()
  if initialized then
    return true
  end

  local opts = vim.g.yourplugin or {}
  M.setup(opts)
  return true
end

---Setup the plugin with user configuration
---Call this function explicitly to configure the plugin,
---or set vim.g.yourplugin for automatic initialization
---@param opts yourplugin.ConfigMeta|nil User configuration options
function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}

  local config = require("yourplugin.config.internal")
  config.setup(opts)

  initialized = true
end

---Example function using configuration
---@return boolean
function M.do_something()
  M._ensure_initialized()
  local config = require("yourplugin.config.internal").get()
  -- config is guaranteed to have all fields
  if config.debug then
    print("Debug mode enabled")
  end
  return true
end

return M
```

## Type Safety Patterns

### Optional vs Guaranteed Types

```lua
-- meta.lua: User can pass partial config
---@class yourplugin.ConfigMeta
---@field enabled boolean|nil  -- User might omit this

-- internal.lua: Internal code always has value
---@class yourplugin.Config
---@field enabled boolean       -- Never nil after setup
```

### Nested Config Classes

```lua
-- Define nested structures separately for clarity
---@class yourplugin.UIConfigMeta
---@field width number|nil
---@field height number|nil

---@class yourplugin.ConfigMeta
---@field ui yourplugin.UIConfigMeta|nil
```

### vim.tbl_deep_extend Usage

```lua
-- Use "force" mode to override defaults with user values
local config = vim.tbl_deep_extend("force", M.defaults, user_opts)

-- Merge order matters: defaults <- user_opts <- vim.g values
```

## Key Points

1. **Separate Concerns**: Meta types for input, internal types for runtime
2. **Lazy by Default**: get() should auto-initialize, setup() should be idempotent
3. **vim.g Support**: Always check vim.g.plugin_name before using defaults
4. **Complete Defaults**: Every internal field must have a default value
5. **Type Annotations**: Use EmmyLua format for all public functions
6. **Testability**: Provide reset() function to clear config state
7. **Merge Order**: User config -> vim.g config -> defaults
8. **Idempotent Setup**: Multiple setup() calls should not re-initialize
9. **Module Pattern**: Use `local M = {}` and `return M` consistently
10. **Documentation**: Document @param types with `|nil` for optional

## References

- `lua/worktrunk/config/meta.lua` - Optional type definitions
- `lua/worktrunk/config/internal.lua` - Internal config with defaults and vim.g support
- `lua/worktrunk/init.lua` - Main plugin initialization pattern
- EmmyLua annotations: https://github.com/LuaLS/lua-language-server/wiki/Annotations
- Neovim Lua guide: https://neovim.io/doc/user/lua-guide.html
