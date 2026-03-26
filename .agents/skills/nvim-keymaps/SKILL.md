---
name: nvim-keymaps
description: Create and manage keyboard mappings in Neovim. Use when defining keybindings, setting up shortcuts, or configuring keyboard shortcuts for plugins.
---

# Neovim Keymaps

## Overview

Create and manage keyboard mappings in Neovim using the modern `vim.keymap.set` API. Supports global and buffer-local mappings across different modes.

## When to Use

- Defining keybindings for custom functionality
- Setting up shortcuts for frequently used commands
- Configuring plugin keymaps
- Creating buffer-local mappings for filetype-specific behavior
- Remapping default Neovim behavior
- Setting up leader key combinations

## Workflow

### 1. Determine the Mode(s) for the Mapping

Choose which mode(s) the keymap should work in:

| Mode | Description |
|------|-------------|
| `'n'` | Normal mode (default) |
| `'i'` | Insert mode |
| `'v'` | Visual and Select mode |
| `'x'` | Visual mode only (no Select) |
| `'s'` | Select mode |
| `'c'` | Command-line mode |
| `'o'` | Operator-pending mode |
| `{'n', 'v'}` | Multiple modes (table/array) |

### 2. Choose the Key Sequence (lhs)

Define the keys that trigger the mapping:

- Use `<leader>` for the leader key
- Use `<localleader>` for buffer-local leader
- Consider ergonomics and avoid conflicts
- Group related mappings under common prefixes

### 3. Define the Action (rhs)

The action can be:

- A command string: `'<cmd>write<cr>'`
- A Lua function: `function() ... end`
- A key sequence: `'ggVG'`

### 4. Set Options

Common options for the mapping:

| Option | Description |
|--------|-------------|
| `desc = "..."` | Description for which-key and `:map` output |
| `silent = true` | Don't echo the command |
| `noremap = true` | Non-recursive mapping (default) |
| `expr = true` | rhs is evaluated as an expression |
| `nowait = true` | Don't wait for more input |
| `buffer = true` | Buffer-local mapping |
| `buffer = bufnr` | Buffer-local with specific buffer number |

### 5. Apply Globally or Buffer-Local

- **Global**: Available in all buffers (default)
- **Buffer-local**: Only in specific buffer with `buffer = true` or `buffer = bufnr`

## Key Notation

| Notation | Description |
|----------|-------------|
| `<leader>` | Leader key (default: `\`) |
| `<localleader>` | Local leader key |
| `<cr>`, `<CR>` | Enter/Return |
| `<esc>` | Escape key |
| `<space>` | Space key |
| `<tab>` | Tab key |
| `<c-x>` | Ctrl+x |
| `<a-x>`, `<m-x>` | Alt+x (Meta) |
| `<s-x>` | Shift+x |
| `<F1>` to `<F12>` | Function keys |
| `<Up>`, `<Down>`, `<Left>`, `<Right>` | Arrow keys |
| `<PageUp>`, `<PageDown>` | Page keys |
| `<Home>`, `<End>` | Home and End |
| `<Insert>`, `<Delete>` | Insert and Delete |

## Code Templates

### Basic Keymap with Command

```lua
-- Save file with <leader>w in normal mode
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })

-- Quit with <leader>q
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })

-- Force quit with <leader>Q
vim.keymap.set('n', '<leader>Q', '<cmd>quit!<cr>', { desc = 'Force quit' })
```

### Keymap with Lua Function

```lua
-- Find files using Telescope
vim.keymap.set('n', '<leader>f', function()
  require('telescope.builtin').find_files()
end, { desc = 'Find files' })

-- Toggle line numbers
vim.keymap.set('n', '<leader>n', function()
  vim.wo.number = not vim.wo.number
  vim.wo.relativenumber = vim.wo.number
end, { desc = 'Toggle line numbers' })

-- Custom function example
local function show_current_time()
  local time = os.date('%H:%M:%S')
  vim.notify('Current time: ' .. time)
end

vim.keymap.set('n', '<leader>t', show_current_time, { desc = 'Show current time' })
```

### Buffer-Local Keymap

```lua
-- Set up buffer-local keymaps in an autocmd or on_attach
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }

    -- Go to definition
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    -- Rename symbol
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
      vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))

    -- Code action
    vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action,
      vim.tbl_extend('force', opts, { desc = 'Code action' }))

    -- Show hover documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover,
      vim.tbl_extend('force', opts, { desc = 'Show documentation' }))
  end,
})
```

### <Plug> Mappings for User Customization

**Why use <Plug>?**
- Allows users to customize keybindings
- Plugin defines functionality, user defines keys
- Follows Vim/Neovim conventions

**Pattern:**
```lua
vim.keymap.set("n", "<Plug>(PluginNameAction)", function()
  require("plugin")._ensure_initialized()
  require("plugin.module").action()
end, { silent = true })
```

**User binding:**
```lua
vim.keymap.set("n", "<leader>p", "<Plug>(PluginNameAction)")
```

**Checking existing mappings:**
```lua
if not vim.fn.hasmapto("<Plug>(PluginNameAction)") then
  vim.keymap.set("n", "<leader>p", "<Plug>(PluginNameAction)")
end
```

## Common Patterns

### Multi-Mode Keymap

```lua
-- Yank to system clipboard in normal and visual mode
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

-- Paste from system clipboard
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
```

### Leader Key Prefixes

```lua
-- File operations
vim.keymap.set('n', '<leader>fs', '<cmd>write<cr>', { desc = '[F]ile [S]ave' })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = '[F]ind [F]iles' })

-- Buffer operations
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = '[B]uffer [D]elete' })

-- Window operations
vim.keymap.set('n', '<leader>wh', '<c-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<leader>wj', '<c-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<leader>wk', '<c-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<leader>wl', '<c-w>l', { desc = 'Move to right window' })
```

### Insert Mode Mappings

```lua
-- Exit insert mode with jj
vim.keymap.set('i', 'jj', '<esc>', { desc = 'Exit insert mode' })

-- Exit insert mode with jk
vim.keymap.set('i', 'jk', '<esc>', { desc = 'Exit insert mode' })

-- Move to end of line in insert mode
vim.keymap.set('i', '<c-e>', '<esc>A', { desc = 'Move to end of line' })

-- Move to beginning of line in insert mode
vim.keymap.set('i', '<c-a>', '<esc>I', { desc = 'Move to beginning of line' })
```

### Visual Mode Mappings

```lua
-- Stay in visual mode when indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and stay in visual' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and stay in visual' })

-- Move selected lines up/down
vim.keymap.set('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })
```

### Command-Line Mode

```lua
-- Better command-line navigation
vim.keymap.set('c', '<c-a>', '<home>', { desc = 'Beginning of line' })
vim.keymap.set('c', '<c-e>', '<end>', { desc = 'End of line' })
vim.keymap.set('c', '<c-p>', '<up>', { desc = 'Previous command' })
vim.keymap.set('c', '<c-n>', '<down>', { desc = 'Next command' })
```

## Tips

- Use `{ desc = '...' }` for all mappings to enable which-key integration
- Prefer `vim.keymap.set` over the legacy `vim.api.nvim_set_keymap`
- Group related mappings under common leader prefixes
- Avoid overriding essential default mappings
- Test mappings in different contexts (different filetypes, with/without plugins)
- Use `<cmd>` instead of `:` in mappings to avoid mode switching
- Buffer-local mappings take precedence over global ones

## References

- `:help vim.keymap.set` - Modern keymap API
- `:help map-overview` - Mapping overview and concepts
- `:help map-modes` - Mapping modes explained (n, v, i, c, etc.)
- `:help key-notation` - Key notation reference
- `:help mapleader` - Leader key configuration
- `:help map-local` - Buffer-local mappings
