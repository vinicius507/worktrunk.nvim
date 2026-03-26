---
name: nvim-lua-doc
description: Document Lua code using LuaCATS/EmmyLua annotations for type checking and LSP support. Use when writing function documentation, adding type annotations, or enabling LSP diagnostics.
---

# LuaCATS/EmmyLua Documentation

Document Lua code with type annotations to enable intelligent completions, diagnostics, and hover documentation in Neovim's LSP.

## When to Use

- Documenting functions with parameters and return values
- Adding type annotations to variables and function signatures
- Enabling LSP diagnostics and type checking
- Writing EmmyLua annotation comments for better IDE support
- Defining custom types, classes, and interfaces
- Creating type aliases for complex structures
- Suppressing intentional diagnostic warnings

## Workflow

1. **Add function documentation** with `@param` tags for each parameter:
   - Include parameter name, type, and description
   - Use `|nil` for optional parameters
   - Use `|` for union types: `string|number`

2. **Document return types** with `@return` tags:
   - List all return values in order
   - Use multiple `@return` lines for multiple values
   - Include descriptions for clarity

3. **Define custom types** with `@class` for complex data structures:
   - Use `@field` for each property
   - Group related fields logically
   - Document field types and purposes

4. **Use type assertions** with `@type` for variables:
   - Cast tables to specific types
   - Override inferred types when needed
   - Use with `@diagnostic disable` for partial configs

5. **Suppress diagnostics** intentionally with `@diagnostic`:
   - Disable specific warnings you expect
   - Use for partial configurations
   - Re-enable with `@diagnostic enable`

## Code Templates

### Function with Full Annotations

```lua
---Process a name with optional configuration
---@param name string The name to process
---@param opts table|nil Optional configuration table
---@return string The processed uppercase name
---@return nil|number Optional length of the name
function M.process(name, opts)
  opts = opts or {}
  return name:upper(), #name
end
```

### Class Definition with Fields

```lua
---Configuration options for the module
---@class CustomConfig
---@field enabled boolean Whether the feature is enabled
---@field timeout number Timeout value in milliseconds
---@field callback function|nil Optional callback function

---Setup the module with configuration
---@param config CustomConfig Configuration object
function M.setup(config)
  if config.enabled then
    -- implementation
  end
end
```

### Type Alias and Usage

```lua
---@alias Mode 'n'|'v'|'i'|'c' Neovim modes (normal, visual, insert, command)
---@alias Handler fun(err: table|nil, result: any, ctx: table, config: table)

---Set the editor mode
---@param mode Mode The mode to switch to
---@param handler Handler|nil Optional handler function
function M.set_mode(mode, handler)
  -- implementation
end
```

## Common Patterns

### Multiple Return Values

```lua
---Parse a configuration string
---@param input string Raw configuration
---@return boolean success Whether parsing succeeded
---@return table|nil result Parsed configuration or nil
---@return string|nil error Error message if failed
function M.parse(input)
  if input == "" then
    return false, nil, "Empty input"
  end
  return true, {}, nil
end
```

### Generic Functions

```lua
---Filter an array
---@generic T
---@param arr T[] Array to filter
---@param predicate fun(item: T): boolean Filter function
---@return T[] Filtered array
function M.filter(arr, predicate)
  local result = {}
  for _, item in ipairs(arr) do
    if predicate(item) then
      table.insert(result, item)
    end
  end
  return result
end
```

### Deprecated Functions

```lua
---@deprecated Use M.new_process() instead
function M.old_process(name)
  return M.new_process(name)
end

---@see M.old_process For migration guide
function M.new_process(name)
  -- new implementation
end
```

### Diagnostic Suppression

```lua
---@diagnostic disable: missing-fields
---Partial LSP configuration without all required fields
---@type vim.lsp.ClientConfig
return {
  settings = {
    lua = {
      diagnostics = { globals = { 'vim' } }
    }
  }
}
---@diagnostic enable: missing-fields
```

## EmmyLua Tag Reference

| Tag | Usage | Example |
|-----|-------|---------|
| `@param` | Parameter type | `---@param name string Description` |
| `@return` | Return type | `---@return number The result` |
| `@class` | Define class | `---@class MyClass` |
| `@field` | Class field | `---@field id number Unique ID` |
| `@type` | Type assertion | `---@type string[]` |
| `@alias` | Type alias | `---@alias Status 'ok'|'error'` |
| `@deprecated` | Mark deprecated | `---@deprecated Use new_fn()` |
| `@see` | Cross-reference | `---@see other_function` |
| `@generic` | Generic type | `---@generic T` |
| `@diagnostic` | Control diagnostics | `---@diagnostic disable: unused` |

## Type Syntax

- **Primitives**: `string`, `number`, `boolean`, `nil`, `function`, `table`, `thread`, `userdata`
- **Arrays**: `string[]`, `number[]`
- **Tables**: `table<string, number>` (key, value types)
- **Functions**: `fun(a: number, b: string): boolean`
- **Unions**: `string|number`, `'a'|'b'|'c'`
- **Literals**: `'literal_value'`
- **Optional**: `string|nil` or `string?`

## References

- `:help lua-guide` - Comprehensive Lua programming guide for Neovim
- `:help lsp` - Overview of LSP support and configuration
- `:help vim.lsp.config` - LSP client configuration options and setup
