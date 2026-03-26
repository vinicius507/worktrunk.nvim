---
name: nvim-testing
description: Test Neovim plugins with Busted framework and vim mocking patterns. Use when writing busted tests, mocking vim functions, clearing package.loaded for isolation, or creating test helpers. Essential for reliable plugin testing with mocked dependencies.
---

# nvim-testing Skill

Testing guide for Neovim plugins using Busted framework with vim function mocking.

## When to Use

- Writing tests for a Neovim Lua plugin
- Testing modules that use `vim.*` API functions
- Testing CLI integrations that use `vim.system()`
- Testing UI components using `vim.ui.select/input`
- Need to isolate tests by clearing module cache
- Creating reusable test helpers

## Busted Structure Overview

Busted is a Lua testing framework that provides:

- `describe()` - Groups related tests
- `it()` - Individual test case
- `before_each()` - Setup before each test
- `after_each()` - Cleanup after each test
- `assert.*` - Assertion helpers

### Common Assertions

```lua
assert.are.equal(expected, actual)
assert.is_true(value)
assert.is_false(value)
assert.is_nil(value)
assert.is_not_nil(value)
assert.is_table(value)
```

## Workflow

### 1. Create Test File

Place test files in `spec/` directory with `_spec.lua` suffix:

```
spec/
  module_spec.lua    # Tests for lua/module.lua
  helpers.lua        # Shared test utilities
```

### 2. Run Tests

```bash
# Run all tests
make test

# Run specific test file
make test-file file=spec/module_spec.lua

# Run tests matching pattern
make test-file file=spec/module_spec.lua -- -t "should do something"

# Run with coverage
make test-coverage
```

### 3. Isolate Tests

Always clear `package.loaded` to get fresh module state:

```lua
before_each(function()
  package.loaded["myplugin.module"] = nil
  package.loaded["myplugin.dependencies"] = nil
end)
```

## Code Templates

### 1. Basic Test File Structure

```lua
describe("myplugin.module", function()
  local module

  before_each(function()
    package.loaded["myplugin.module"] = nil
    module = require("myplugin.module")
  end)

  describe("function_name", function()
    it("should do something", function()
      local result = module.function_name()
      assert.are.equal("expected", result)
    end)

    it("should handle edge case", function()
      local result = module.function_name(nil)
      assert.is_nil(result)
    end)
  end)
end)
```

### 2. package.loaded Clearing Pattern

```lua
describe("myplugin.module", function()
  local module

  before_each(function()
    -- Clear the module being tested
    package.loaded["myplugin.module"] = nil
    
    -- Clear dependencies to ensure fresh state
    package.loaded["myplugin.api"] = nil
    package.loaded["myplugin.config"] = nil
    
    -- Clear vim.g config
    vim.g.myplugin = nil
    
    -- Require fresh copy
    module = require("myplugin.module")
  end)

  after_each(function()
    vim.g.myplugin = nil
  end)
end)
```

### 3. vim.system Mocking Helper

```lua
-- In spec/helpers.lua
local M = {}

function M.mock_vim_system(result)
  local original = vim.system
  vim.system = function(cmd, opts, callback)
    if callback then
      callback(result)
    end
    return {
      wait = function()
        return result
      end,
    }
  end
  return function()
    vim.system = original
  end
end

return M
```

Usage in test:

```lua
local helpers = require("spec.helpers")

it("should call external command", function()
  local mock_result = {
    code = 0,
    stdout = "success output",
    stderr = "",
  }

  local restore = helpers.mock_vim_system(mock_result)

  local result = module.call_cli()
  assert.is_true(result)

  restore()
end)
```

### 4. vim.ui Mocking Helper

```lua
-- In spec/helpers.lua
function M.mock_vim_ui()
  local original_select = vim.ui.select
  local original_input = vim.ui.input
  local original_cmd = vim.cmd

  -- Mock picker to select first item
  vim.ui.select = function(items, opts, on_choice)
    if #items > 0 then
      on_choice(items[1], 1)
    else
      on_choice(nil, nil)
    end
  end

  -- Mock input to return test value
  vim.ui.input = function(opts, on_confirm)
    on_confirm("test-input")
  end

  -- Mock vim.cmd to avoid side effects
  vim.cmd = function(cmd)
    -- No-op
  end

  return function()
    vim.ui.select = original_select
    vim.ui.input = original_input
    vim.cmd = original_cmd
  end
end
```

Usage in test:

```lua
local restore_ui

before_each(function()
  restore_ui = helpers.mock_vim_ui()
end)

after_each(function()
  if restore_ui then
    restore_ui()
  end
end)

it("should show picker", function()
  -- Test won't prompt for input, auto-selects first item
  local result = module.show_picker()
  assert.is_not_nil(result)
end)
```

### 5. Config Test with vim.g

```lua
describe("myplugin.config", function()
  local config

  before_each(function()
    package.loaded["myplugin.config"] = nil
    vim.g.myplugin = nil
    config = require("myplugin.config")
  end)

  after_each(function()
    vim.g.myplugin = nil
    config.reset()  -- If available
  end)

  it("should use vim.g configuration", function()
    vim.g.myplugin = { option = "value" }
    config.setup()
    
    local cfg = config.get()
    assert.are.equal("value", cfg.option)
  end)

  it("should merge nested config", function()
    config.setup({
      ui = {
        width = 80,
      },
    })
    local cfg = config.get()

    assert.are.equal(80, cfg.ui.width)
    assert.are.equal(40, cfg.ui.height)  -- Default preserved
  end)
end)
```

### 6. Error Testing Pattern

```lua
describe("parse_error", function()
  it("should identify specific error", function()
    local stderr = "Error: branch 'nonexistent' not found"
    local error_type = module.parse_error(stderr)

    assert.are.equal("branch_not_found", error_type)
  end)

  it("should return unknown for unrecognized errors", function()
    local stderr = "Some random error"
    local error_type = module.parse_error(stderr)

    assert.are.equal("unknown", error_type)
  end)

  it("should handle nil input", function()
    local error_type = module.parse_error(nil)
    assert.are.equal("unknown", error_type)
  end)
end)

-- Test error conditions with mocked CLI
it("should return false on error", function()
  local mock_result = {
    code = 1,
    stdout = "",
    stderr = "Error: something failed",
  }

  local restore = helpers.mock_vim_system(mock_result)

  local success = module.operation()
  assert.is_false(success)

  restore()
end)
```

### 7. Complete Test File Example

```lua
describe("myplugin.core", function()
  local core
  local helpers = require("spec.helpers")

  before_each(function()
    package.loaded["myplugin.core"] = nil
    package.loaded["myplugin.api.cli"] = nil
    package.loaded["myplugin.config.internal"] = nil
    require("myplugin.config.internal").setup()
    core = require("myplugin.core")
  end)

  describe("list", function()
    it("should call list command", function()
      local mock_result = helpers.mock_wt_list_output({
        { name = "item1", path = "/path/1" },
        { name = "item2", path = "/path/2" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local items = core.list()

      assert.are.equal(2, #items)
      assert.are.equal("item1", items[1].name)

      restore()
    end)

    it("should return empty table on error", function()
      local mock_result = {
        code = 1,
        stdout = "",
        stderr = "command not found",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local items = core.list()

      assert.are.equal(0, #items)

      restore()
    end)
  end)

  describe("process", function()
    it("should process item", function()
      local mock_result = {
        code = 0,
        stdout = "Processed",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.process("item1")

      assert.is_true(success)

      restore()
    end)
  end)
end)
```

## Mocking Patterns

### CLI Output Helper

```lua
-- Helper for CLI that returns JSON
function M.mock_wt_list_output(items)
  local stdout = vim.json.encode(items)
  return {
    code = 0,
    stdout = stdout,
    stderr = "",
  }
end
```

### vim.notify Mocking

```lua
it("should show error notification", function()
  local notified = false
  local original_notify = vim.notify
  vim.notify = function(msg, level)
    notified = true
    assert.is_truthy(msg:match("error pattern"))
  end

  module.operation_that_fails()

  assert.is_true(notified)

  vim.notify = original_notify
end)
```

### Multiple Mocks in One Test

```lua
it("should handle complex interaction", function()
  local restore_system = helpers.mock_vim_system({
    code = 0,
    stdout = "output",
    stderr = "",
  })
  local restore_ui = helpers.mock_vim_ui()

  -- Test code here
  local result = module.complex_operation()
  assert.is_true(result)

  restore_ui()
  restore_system()
end)
```

## Key Points

1. **Always clear package.loaded** before each test to get fresh module state
2. **Restore mocks** after tests to avoid affecting other tests
3. **Use helpers.lua** for reusable mock utilities
4. **Test error conditions** by mocking stderr and checking error handling
5. **Mock vim.ui** to avoid interactive prompts in tests
6. **Reset vim.g** after config tests to avoid state pollution
7. **Group related tests** with nested describe blocks
8. **Use meaningful test names** starting with "should"
9. **Test both success and failure** cases
10. **Mock external dependencies** (CLI tools, file system) to make tests reliable

## References

- Busted documentation: https://lunarmodules.github.io/busted/
- Neovim Lua API: https://neovim.io/doc/user/lua.html
- Test examples:
  - `spec/core_spec.lua` - vim.system mocking, error testing
  - `spec/config_spec.lua` - vim.g integration, config testing
  - `spec/helpers.lua` - Mock utilities
  - `spec/commands_spec.lua` - Complex test organization
