---
name: nvim-autocmds
description: Create and manage autocommands and augroups in Neovim. Use when setting up automatic actions on events, creating hooks for file operations, or organizing related autocommands.
---

# Neovim Autocommands and Augroups

## When to Use

Set up autocommands when you need:

- **Auto-formatting on save** - Run formatters when files are written
- **Highlighting on yank** - Visual feedback when copying text
- **Filetype-specific actions** - Enable features for specific file types
- **Window management hooks** - Resize or reposition windows automatically
- **LSP integrations** - Trigger actions on buffer events
- **Custom workflows** - Automate repetitive editor tasks

## Workflow

### 1. Create an Augroup to Organize Related Autocommands

Always create an augroup with `{ clear = true }` to prevent duplicate autocommands on reload:

```lua
local group = vim.api.nvim_create_augroup("custom.name", { clear = true })
```

**Naming convention:** Use dot notation for hierarchical naming:
- `user.highlight` - User's highlight-related autocommands
- `lsp.format` - LSP formatting autocommands
- `ui.custom` - UI customization autocommands

### 2. Define the Autocommand with Event(s)

Create the autocommand and assign it to the augroup:

```lua
vim.api.nvim_create_autocmd("Event", {
  group = group,
  -- ...
})
```

### 3. Set the Pattern or Buffer Constraint

**File patterns:** Target specific file types:
```lua
pattern = "*.lua",
pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
```

**Buffer-local:** Target a specific buffer number:
```lua
buffer = bufnr,
```

**All buffers:** Omit pattern/buffer for global scope

### 4. Add Description for Clarity

Always add descriptions for debugging and documentation:

```lua
desc = "Format Lua files before saving",
```

### 5. Implement Callback or Command

Use **callback** for Lua functions:
```lua
callback = function(args)
  -- Your logic here
end,
```

Use **command** for Vim commands:
```lua
command = "echo 'File saved!'",
```

## Code Templates

### Augroup with Callback Function

```lua
local my_group = vim.api.nvim_create_augroup("custom.mygroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = my_group,
  pattern = "*.lua",
  desc = "Format before saving",
  callback = function(args)
    vim.lsp.buf.format({ timeout_ms = 2000 })
  end,
})
```

### Autocommand with Vim Command

```lua
local ui_group = vim.api.nvim_create_augroup("ui.custom", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ui_group,
  pattern = { "help", "qf" },
  desc = "Close help/quickfix with q",
  command = "nnoremap <buffer> q <cmd>quit<cr>",
})
```

### Buffer-local Autocommand

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = bufnr,
  desc = "Format current buffer only",
  callback = function()
    vim.lsp.buf.format()
  end,
})
```

## Common Patterns

### Highlight on Yank

```lua
local highlight_group = vim.api.nvim_create_augroup("highlight.yank", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  desc = "Highlight when yanking text",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
```

### Auto-format on Save

```lua
local format_group = vim.api.nvim_create_augroup("format.on_save", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = "*.lua",
  desc = "Format Lua files before saving",
  callback = function(args)
    vim.lsp.buf.format({ timeout_ms = 2000 })
  end,
})
```

### Filetype-specific Settings

```lua
local ft_group = vim.api.nvim_create_augroup("filetype.custom", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "markdown",
  desc = "Enable wrap for markdown files",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
```

## Common Events

| Event | When Fired |
|-------|------------|
| `BufEnter` | Entering a buffer |
| `BufLeave` | Leaving a buffer |
| `BufReadPost` | After reading a file into buffer |
| `BufWritePre` | Before writing buffer to file |
| `BufWritePost` | After writing buffer to file |
| `FileType` | Filetype detected/set |
| `TextYankPost` | After yanking text |
| `VimEnter` | After Vim initializes |
| `VimLeavePre` | Before exiting Vim |
| `WinEnter` | Entering a window |
| `WinLeave` | Leaving a window |
| `InsertEnter` | Entering insert mode |
| `InsertLeave` | Leaving insert mode |
| `CursorHold` | Cursor idle for 'updatetime' |
| `CursorMoved` | Cursor moved in normal mode |

## Key Points

- **Always use augroups** with `{ clear = true }` to prevent duplicates
- **Use descriptive names** with dot notation for organization
- **Add descriptions** to all autocommands for debugging
- **Prefer callbacks** over commands for Lua logic
- **Check `args.buf`** in callbacks for the buffer number
- **Use buffer-local options** (`opt_local`) in filetype autocommands

## References

- `:help autocmd` - Autocommands overview
- `:help nvim_create_autocmd` - Create autocommands API
- `:help nvim_create_augroup` - Create augroups API
- `:help events` - List of available events
