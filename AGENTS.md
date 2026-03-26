# AGENTS.md - worktrunk.nvim

Guidelines for AI agents working on this Neovim plugin for git worktree management.

## Project Overview

A Neovim plugin providing tight integration with the worktrunk CLI tool. Written in Lua 5.1 for Neovim 0.9+.

## Build/Test/Lint Commands

```bash
# Run all tests
make test

# Run specific test file
make test-file file=spec/core_spec.lua

# Run specific test by name pattern
make test-file file=spec/core_spec.lua -- -t "should call wt switch"

# Run tests with coverage
make test-coverage

# Run tests in current Neovim (for debugging)
make test-debug

# Lint with luacheck
make lint

# Check formatting with stylua
make format

# Apply formatting fixes
make format-fix

# Type check with lua-language-server
make typecheck
```

## Code Style Guidelines

### Formatting (Stylua)
- **Indentation**: 2 spaces (no tabs)
- **Column width**: 120 characters
- **Line endings**: Unix (LF)
- **Quotes**: Auto-prefer double quotes
- **Call parentheses**: Always required
- **Simple statements**: Never collapse (keep on separate lines)

### Lua Conventions
- **Language**: Lua 5.1 (Neovim compatibility)
- **Module pattern**: Use `local M = {}` and return M at end
- **Naming**: snake_case for variables, functions, modules
- **Private functions**: Prefix with underscore (e.g., `_ensure_initialized`)
- **Constants**: UPPER_SNAKE_CASE for true constants

### Type Annotations
- Use EmmyLua annotation format
- Annotate all public functions with `@param` and `@return`
- Define classes with `@class` for complex types
- Use `@module` at top of file

Example:
```lua
---@module "worktrunk.core"
local M = {}

---@class worktrunk.Worktree
---@field branch string
---@field path string

---Parse worktree list output
---@param output string
---@return worktrunk.Worktree[]
function M.parse_list(output)
  -- implementation
end
```

### Imports
- Use `require("module.name")` with double quotes
- Lazy-load dependencies inside functions when possible
- Clear package.loaded in tests for isolation

### Error Handling
- Return `(boolean, string|nil)` pattern for operations that can fail
- Use `pcall()` for protected calls with validation
- Parse error messages from CLI tools using pattern matching
- Return error type strings (e.g., "branch_not_found", "worktree_exists")

### Async Patterns
- Use `vim.system()` for external command execution
- Wrap async calls in `pcall()` for error handling
- Use `:wait()` to get synchronous results when needed

### Testing (Busted)
- Test files: `spec/*_spec.lua`
- Use `describe()` and `it()` blocks
- `before_each()` for setup, clear package.loaded
- Use `assert.are.equal()`, `assert.is_true()`, `assert.is_nil()`
- Mock vim functions via `helpers.mock_vim_system()`
- Always restore mocks after tests

Example:
```lua
describe("module", function()
  before_each(function()
    package.loaded["worktrunk.module"] = nil
  end)

  it("should do something", function()
    local result = require("worktrunk.module").function()
    assert.are.equal("expected", result)
  end)
end)
```

### Neovim API
- Use `vim.api.nvim_*` functions directly
- Use `vim.fn.*` for vimscript functions
- Use `vim.keymap.set()` for mappings
- Use `vim.notify()` for user messages
- Use `vim.validate()` for config validation
- Use `vim.tbl_deep_extend()` for table merging
- Use `vim.json.encode/decode` for JSON handling

### Project Structure
```
lua/worktrunk/
  init.lua          # Main module, public API
  core.lua          # Backward compatibility shim
  commands.lua      # Command implementations (deprecated)
  commands/
    init.lua        # Command registration
  config/
    init.lua        # Configuration setup
    meta.lua        # Config type definitions
    internal.lua    # Internal config state
  api/
    cli.lua         # CLI API wrapper
  util/
    error.lua       # Error handling utilities
    path.lua        # Path utilities
  ui/
    picker.lua      # UI picker integration
    notify.lua      # Notification utilities
  health.lua        # Health check

plugin/
  worktrunk.lua     # User commands, keymaps

spec/               # Test files
  *_spec.lua        # Busted tests
  helpers.lua       # Test utilities
```

### Key Principles
- Keep modules focused and single-purpose
- Initialize lazily via `_ensure_initialized()` pattern
- Support both Lua API and vim commands
- Mock external dependencies (wt CLI) in tests
- Never commit secrets or credentials
- All files must pass luacheck and stylua

### External Dependencies
- **worktrunk CLI**: External binary `wt` must be installed
- **Neovim**: Version 0.9+ required
- **Lua**: Version 5.1 for compatibility
