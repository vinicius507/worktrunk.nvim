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

# Run tests with coverage
make test-coverage

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

### Project Structure
```
lua/worktrunk/
  init.lua       # Main module, public API
  core.lua       # Core business logic
  config/        # Configuration
    init.lua     # Config module
  commands.lua   # Command implementations
  health.lua     # Health check

plugin/
  worktrunk.lua  # User commands, keymaps

spec/            # Test files
  *_spec.lua     # Busted tests
  helpers.lua    # Test utilities
```

### Key Principles
- Keep modules focused and single-purpose
- Initialize lazily via `_ensure_initialized()` pattern
- Support both Lua API and vim commands
- Mock external dependencies (wt CLI) in tests
- Never commit secrets or credentials
- All files must pass luacheck and stylua