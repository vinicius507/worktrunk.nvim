---
name: nvim-lazy-loading
description: Implement lazy loading patterns for Neovim plugins to improve startup performance. Use when deferring module requires, creating plugin/ directory structures, implementing _ensure_initialized patterns, or avoiding eager imports at startup.
---

# Lazy Loading for Neovim Plugins

Guide for implementing deferred loading patterns to minimize startup time and improve Neovim performance.

## When to Use

- Creating new Neovim plugins that need fast startup
- Refactoring existing plugins to reduce require() overhead
- Deferring heavy module loading until first use
- Separating command/keymap definitions from implementation
- Supporting both lazy.nvim and manual lazy loading

## Why Lazy Loading Matters

Neovim's startup time is affected by every `require()` at the module level. By deferring requires until functions are actually called:

- **Faster startup**: Only load code when needed
- **Lower memory**: Unused features don't consume resources
- **Better UX**: Immediate editor availability
- **Modular design**: Clear separation between interface and implementation

## Workflow

1. **Structure your plugin** with `plugin/` for interface and `lua/` for implementation
2. **Create initialization guard** using `_ensure_initialized()` pattern
3. **Defer all requires** inside functions, not at module level
4. **Define commands in plugin/** with lazy initialization
5. **Use <Plug> mappings** for user-customizable keybindings
6. **Support vim.g auto-setup** for zero-config usage

## Directory Structure

```
my-plugin/
├── plugin/
│   └── my-plugin.lua       # Commands, <Plug> mappings (loads at startup)
├── lua/
│   └── my-plugin/
│       ├── init.lua        # Public API with _ensure_initialized()
│       ├── config.lua      # Configuration handling
│       └── commands.lua    # Command implementations (lazy loaded)
└── README.md
```

Key principle: `plugin/` files load at startup (keep minimal), `lua/` files load on demand.

## Code Templates

### 1. _ensure_initialized() Pattern

Lazy initialization guard that auto-configures from `vim.g`:

```lua
-- lua/my-plugin/init.lua
local M = {}

local initialized = false

---Ensure plugin is initialized (lazy initialization)
---Called automatically before any API function
---@return boolean
function M._ensure_initialized()
  if initialized then
    return true
  end

  -- Auto-setup from vim.g if not explicitly configured
  local opts = vim.g.my_plugin or {}
  M.setup(opts)
  return true
end

---Setup the plugin with user configuration
---@param opts table|nil User configuration options
function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}

  -- Initialize configuration
  local config = require("my-plugin.config")
  config.setup(opts)

  initialized = true
end

return M
```

### 2. Deferred require() Inside Functions

Never require at module level; require inside functions when needed:

```lua
-- lua/my-plugin/init.lua

-- BAD: Loads immediately at startup
local heavy_module = require("my-plugin.heavy_module")

-- GOOD: Only loads when function is called
function M.do_something()
  M._ensure_initialized()
  local heavy_module = require("my-plugin.heavy_module")
  return heavy_module.process()
end
```

Full example with multiple API functions:

```lua
-- lua/my-plugin/init.lua
local M = {}
local initialized = false

function M._ensure_initialized()
  if initialized then
    return true
  end
  local opts = vim.g.my_plugin or {}
  M.setup(opts)
  return true
end

function M.setup(opts)
  if initialized then
    return
  end
  require("my-plugin.config").setup(opts or {})
  initialized = true
end

-- Each function defers require() until called
function M.list(opts)
  M._ensure_initialized()
  return require("my-plugin.api").list(opts)
end

function M.create(name, opts)
  M._ensure_initialized()
  return require("my-plugin.api").create(name, opts)
end

function M.delete(name)
  M._ensure_initialized()
  return require("my-plugin.api").delete(name)
end

return M
```

### 3. Command Registration in plugin/

Define commands without loading full plugin:

```lua
-- plugin/my-plugin.lua

vim.api.nvim_create_user_command("MyPlugin", function(opts)
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute(opts.args)
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    -- Initialize and provide completions without eager loading
    require("my-plugin")._ensure_initialized()
    return require("my-plugin.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "My plugin command",
})

-- Subcommand example
vim.api.nvim_create_user_command("MyPluginList", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute("list")
end, {
  desc = "List items",
})
```

### 4. <Plug> Mappings with Lazy Require

Define mappings in plugin/ that defer loading:

```lua
-- plugin/my-plugin.lua

-- Define <Plug> mappings - users bind their own keys
vim.keymap.set("n", "<Plug>(MyPluginList)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute("list")
end, { silent = true })

vim.keymap.set("n", "<Plug>(MyPluginCreate)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute("create")
end, { silent = true })

vim.keymap.set("n", "<Plug>(MyPluginDelete)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute("delete")
end, { silent = true })

vim.keymap.set("n", "<Plug>(MyPluginToggle)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.ui").toggle()
end, { silent = true })
```

Users configure keymaps in their config (e.g., `~/.config/nvim/init.lua`):

```lua
-- User's init.lua
vim.keymap.set("n", "<leader>pl", "<Plug>(MyPluginList)")
vim.keymap.set("n", "<leader>pc", "<Plug>(MyPluginCreate)")
vim.keymap.set("n", "<leader>pd", "<Plug>(MyPluginDelete)")
vim.keymap.set("n", "<leader>pt", "<Plug>(MyPluginToggle)")
```

### 5. vim.g Auto-Setup

Support zero-config initialization from global variables:

```lua
-- lua/my-plugin/init.lua

function M._ensure_initialized()
  if initialized then
    return true
  end

  -- Read configuration from vim.g.my_plugin
  local opts = vim.g.my_plugin or {}
  M.setup(opts)
  return true
end
```

Users can configure without calling setup():

```lua
-- User's init.lua (Option 1: vim.g)
vim.g.my_plugin = {
  enabled = true,
  auto_save = true,
  keymaps = {
    list = "<leader>pl",
  }
}
-- No setup() call needed!

-- Or (Option 2: explicit setup)
require("my-plugin").setup({
  enabled = true,
  auto_save = true,
})
```

### 6. Complete Lazy-Loading Structure

Complete plugin structure demonstrating all patterns:

**plugin/my-plugin.lua** (loads at startup - keep minimal):
```lua
-- Commands
vim.api.nvim_create_user_command("MyPlugin", function(opts)
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").execute(opts.args)
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    require("my-plugin")._ensure_initialized()
    return require("my-plugin.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "My plugin",
})

-- <Plug> mappings
vim.keymap.set("n", "<Plug>(MyPluginList)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").list()
end, { silent = true })

vim.keymap.set("n", "<Plug>(MyPluginCreate)", function()
  require("my-plugin")._ensure_initialized()
  require("my-plugin.commands").create()
end, { silent = true })
```

**lua/my-plugin/init.lua** (lazy-loaded API):
```lua
---@module "my-plugin"
local M = {}

local initialized = false

function M._ensure_initialized()
  if initialized then
    return true
  end
  local opts = vim.g.my_plugin or {}
  M.setup(opts)
  return true
end

function M.setup(opts)
  if initialized then
    return
  end
  require("my-plugin.config").setup(opts or {})
  initialized = true
end

-- API functions with deferred requires
function M.list(opts)
  M._ensure_initialized()
  return require("my-plugin.core").list(opts)
end

function M.create(name, opts)
  M._ensure_initialized()
  return require("my-plugin.core").create(name, opts)
end

return M
```

**lua/my-plugin/config.lua** (configuration):
```lua
---@module "my-plugin.config"
local M = {}

---@class MyPluginConfig
---@field enabled boolean
---@field auto_save boolean

local default_config = {
  enabled = true,
  auto_save = false,
}

local current_config = {}

function M.setup(opts)
  current_config = vim.tbl_deep_extend("force", default_config, opts or {})
end

function M.get()
  return current_config
end

return M
```

**lua/my-plugin/core.lua** (heavy implementation):
```lua
---@module "my-plugin.core"
local M = {}

-- Heavy dependencies only loaded when core is required
local heavy_lib = require("third-party.heavy-lib")
local parser = require("my-plugin.parser")

function M.list(opts)
  -- Implementation
end

function M.create(name, opts)
  -- Implementation
end

return M
```

## Key Points

- **plugin/ files load at startup**: Keep them minimal - only commands and mappings
- **lua/ files load on demand**: Heavy implementation stays deferred
- **_ensure_initialized() is idempotent**: Safe to call multiple times
- **vim.g integration**: Enables zero-config usage for users
- **<Plug> mappings**: Give users control over keybindings
- **Defer all requires**: Even config requires should be inside functions when possible
- **Complete function**: Tab completion should also use lazy initialization
- **Silent mappings**: Use `{ silent = true }` for <Plug> mappings

## References

- [worktrunk.nvim lua/worktrunk/init.lua](lua/worktrunk/init.lua) - _ensure_initialized(), deferred requires
- [worktrunk.nvim plugin/worktrunk.lua](plugin/worktrunk.lua) - Commands and <Plug> mappings
- [Neovim :help lazy-load](https://neovim.io/doc/user/usr_05.html#_sourcing-the-plugins-lazily) - Official documentation
- [lazy.nvim documentation](https://lazy.folke.io/) - Plugin manager with lazy loading
