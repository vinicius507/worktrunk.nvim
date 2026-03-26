# worktrunk.nvim

A Neovim plugin that provides tight integration with the worktrunk CLI tool for git worktree management.

## Features

- **Worktree List**: Browse all worktrees with metadata via `vim.ui.select`
- **Worktree Switch**: Switch between worktrees with automatic directory navigation
- **Worktree Create**: Create new worktrees from branches with interactive prompts
- **Worktree Remove**: Safely remove worktrees with confirmation
- **Pure vim.ui**: No telescope/snacks dependencies - uses native Neovim UI
- **Command Completion**: Full completion for `:Worktree` subcommands and branch names

## Requirements

- Neovim 0.9+
- [worktrunk CLI](https://worktrunk.dev) (`wt` command)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "vinicius507/worktrunk.nvim",
  dependencies = {},
  config = function()
    require("worktrunk").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "vinicius507/worktrunk.nvim",
  config = function()
    require("worktrunk").setup()
  end,
}
```

## Configuration

```lua
require("worktrunk").setup({
  wt_cmd = "wt",              -- Path to wt binary
  auto_cd = true,             -- Auto-change directory on switch
  confirm_remove = true,      -- Confirm before removing
  enable_events = true,       -- Enable autocommands
  ui = {
    show_full_paths = false,
    picker_width = 60,
    show_preview = true,
  },
  hooks = {
    async = true,
    show_output = true,
    timeout = 0,
  },
  pr = {
    enabled = true,
    tool = nil, -- "gh" or "glab", auto-detect if nil
  },
})
```

## Usage

### Commands

```vim
" List worktrees interactively
:Worktree list

" Switch to existing worktree
:Worktree switch feature-branch

" Create and switch to new worktree
:Worktree switch --create new-feature

" Create from base branch
:Worktree create hotfix --base=production

" Remove with confirmation
:Worktree remove old-feature

" Show current worktree
:Worktree current
```

### Keymaps

```lua
-- Suggested keymaps
vim.keymap.set("n", "<leader>gwl", "<Plug>(WorktreeList)", { desc = "List worktrees" })
vim.keymap.set("n", "<leader>gws", "<Plug>(WorktreeSwitch)", { desc = "Switch worktree" })
vim.keymap.set("n", "<leader>gwc", "<Plug>(WorktreeCreate)", { desc = "Create worktree" })
vim.keymap.set("n", "<leader>gwd", "<Plug>(WorktreeRemove)", { desc = "Delete worktree" })
```

### Lua API

```lua
local wt = require("worktrunk")

-- List all worktrees
local worktrees = wt.list()

-- Switch to a worktree
wt.switch("feature-branch")

-- Create a new worktree
wt.create("hotfix", "main")

-- Remove a worktree
wt.remove("old-branch")

-- Get current worktree
local current = wt.current()

-- Statusline component
vim.o.statusline = "%{v:lua.require('worktrunk').statusline()}"
```

## Health Check

Run `:checkhealth worktrunk` to verify your installation.

## License

MIT
