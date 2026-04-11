# worktrunk.nvim

A Neovim plugin that provides tight integration with the worktrunk CLI tool for git worktree management.

## Features

- **Worktree List**: Browse all worktrees with metadata via `vim.ui.select`
- **Worktree Switch**: Switch between worktrees with automatic directory navigation
- **Worktree Create**: Create new worktrees from branches with interactive prompts
- **Worktree Remove**: Safely remove worktrees with confirmation
- **Worktree Merge**: Merge current branch into target with various options
- **Worktree Step**: Run step commands (commit, squash, rebase, push, diff, copy-ignored)
- **Hooks Support**: Run and manage worktrunk hooks
- **Pure vim.ui**: No telescope/snacks dependencies - uses native Neovim UI
- **Command Completion**: Full completion for `:Worktree` subcommands and branch names
- **PR/MR Shortcuts**: Quick switch to PR/MR branches (e.g., `pr:123`, `mr:456`)

## Requirements

- Neovim 0.9+
- [worktrunk CLI](https://worktrunk.dev) (`wt` command)
- Optional: `gh` CLI for GitHub PR support
- Optional: `glab` CLI for GitLab MR support

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

### Using `vim.pack` (Neovim 0.11+)

```lua
vim.pack.add({
  "https://github.com/vinicius507/worktrunk.nvim",
})

require("worktrunk").setup()
```

## Configuration

```lua
require("worktrunk").setup({
  wt_cmd = "wt",              -- Path to wt binary
  auto_cd = true,             -- Auto-change directory on switch
  confirm_remove = true,      -- Confirm before removing
  enable_events = true,         -- Enable autocommands for worktree events
  ui = {
    show_full_paths = false,    -- Show full paths in picker
    picker_width = 60,          -- Width of the picker window
    show_preview = true,        -- Show worktree preview
  },
  hooks = {
    async = true,               -- Run hooks asynchronously
    show_output = true,         -- Show hook output
    timeout = 0,                -- Hook timeout (0 = no timeout)
  },
  pr = {
    enabled = true,             -- Enable PR/MR shortcuts
    tool = nil,                 -- "gh" or "glab", auto-detect if nil
  },
})
```

### Configuration via `vim.g.worktrunk`

You can also configure via global variable:

```lua
vim.g.worktrunk = {
  auto_cd = false,
  confirm_remove = false,
}
```

## Usage

### Commands

#### List Worktrees

```vim
" List worktrees interactively (default)
:Worktree
:Worktree list

" Include all branches/remotes
:Worktree list --branches --remotes

" Show full details
:Worktree list --full

" Progressive display
:Worktree list --progressive
```

#### Switch Worktrees

```vim
" Switch to existing worktree
:Worktree switch feature-branch

" Create and switch to new worktree
:Worktree switch --create new-feature
:Worktree switch -c new-feature

" Create from base branch
:Worktree switch --create hotfix --base=production
:Worktree switch -c hotfix -b production

" Switch without changing directory
:Worktree switch feature-branch --no-cd

" Switch with clobber (force overwrite)
:Worktree switch --create feature --clobber

" Auto-confirm
:Worktree switch feature-branch --yes
:Worktree switch feature-branch -y

" Skip verification
:Worktree switch feature-branch --no-verify

" Execute command after switch
:Worktree switch feature-branch --execute "npm install"
:Worktree switch feature-branch -x "npm install"

" Special shortcuts
:Worktree switch -          " Switch to previous worktree
:Worktree switch @          " Switch to main worktree
:Worktree switch pr:123     " Switch to PR #123 (requires gh)
:Worktree switch mr:456     " Switch to MR #456 (requires glab)
```

#### Create Worktrees

```vim
" Create from current branch
:Worktree create new-feature

" Create from specific base
:Worktree create hotfix --base=main
:Worktree create hotfix -b main
```

#### Remove Worktrees

```vim
" Remove with confirmation
:Worktree remove old-feature

" Force remove
:Worktree remove old-feature --force
:Worktree remove old-feature -f

" Force delete branch
:Worktree remove old-feature --force-delete
:Worktree remove old-feature -D

" Remove without deleting branch
:Worktree remove old-feature --no-delete-branch

" Auto-confirm removal
:Worktree remove old-feature --yes
:Worktree remove old-feature -y

" Interactive removal (no args)
:Worktree remove
```

#### Show Current Worktree

```vim
:Worktree current
```

#### Merge

```vim
" Merge current branch into target
:Worktree merge main

" Merge without squashing
:Worktree merge --no-squash

" Merge without committing
:Worktree merge --no-commit

" Merge without rebasing
:Worktree merge --no-rebase

" Merge without removing worktree after
:Worktree merge --no-remove

" Disable fast-forward
:Worktree merge --no-ff

" Stage options
:Worktree merge --stage=all
:Worktree merge --stage=tracked
:Worktree merge --stage=none
```

#### Step Commands

```vim
" Run step subcommands
:Worktree step commit
:Worktree step squash
:Worktree step rebase
:Worktree step push
:Worktree step diff
:Worktree step copy-ignored

" With stage options
:Worktree step commit --stage=all
```

#### Hooks

```vim
" Show available hooks
:Worktree hooks

" Run specific hooks
:Worktree hooks show
:Worktree hooks pre-switch
:Worktree hooks post-create
:Worktree hooks post-start
:Worktree hooks post-switch
:Worktree hooks pre-commit
:Worktree hooks pre-merge
:Worktree hooks post-merge
:Worktree hooks pre-remove
:Worktree hooks post-remove
:Worktree hooks approvals
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

-- Setup (optional - will auto-initialize)
wt.setup({
  auto_cd = true,
  confirm_remove = true,
})

-- List all worktrees
local ok, worktrees = wt.list()
if ok then
  for _, w in ipairs(worktrees) do
    print(w.branch .. " at " .. w.path)
  end
end

-- List with options
local ok, worktrees = wt.list({
  branches = true,
  remotes = true,
  full = true,
})

-- Switch to a worktree
wt.switch("feature-branch")

-- Switch with options
wt.switch("feature-branch", {
  create = true,
  base = "main",
  no_cd = false,
})

-- Create a new worktree
wt.create("hotfix", "main")

-- Create with options
wt.create("feature", "develop", {
  yes = true,
  no_verify = true,
})

-- Remove a worktree
wt.remove("old-branch")

-- Remove with options
wt.remove("old-branch", {
  force = true,
  force_delete = true,
  yes = true,
})

-- Merge current branch into target
wt.merge("main")

-- Merge with options
wt.merge("main", {
  no_squash = true,
  no_commit = false,
  no_rebase = false,
  no_remove = false,
  no_ff = false,
  stage = "all",
})

-- Run step commands
wt.step("commit")
wt.step("squash")
wt.step("rebase")
wt.step("push")
wt.step("diff")
wt.step("copy-ignored")

-- Run hooks (placeholder - not yet implemented)
-- wt.run_hook("pre-switch")

-- Get current worktree
local ok, current = wt.current()
if ok and current then
  print("Current: " .. current.branch)
end

-- Statusline component
vim.o.statusline = "%{v:lua.require('worktrunk').statusline()}"
-- or
vim.o.statusline = "%!v:lua.require('worktrunk').statusline()"
```

### Worktree Object

The `wt.list()` and `wt.current()` functions return worktree objects with the following structure:

```lua
{
  branch = "feature-branch",      -- Branch name
  path = "/path/to/worktree",     -- Absolute path
  kind = "worktree",              -- "worktree" or "branch"
  commit = {
    sha = "abc123...",
    short_sha = "abc123",
    message = "Commit message",
    timestamp = 1699999999,
  },
  working_tree = {
    staged = false,
    modified = true,
    untracked = false,
    renamed = false,
    deleted = false,
    diff = { added = 10, deleted = 5 },
  },
  main_state = "ahead",           -- ahead/behind/diverged status
  is_main = false,                -- Is this the main worktree?
  is_current = true,              -- Is currently checked out?
  is_previous = false,            -- Was this the previous worktree?
  symbols = "*+",                 -- Status symbols
}
```

## Health Check

Run `:checkhealth worktrunk` to verify your installation. This checks:

- worktrunk CLI (`wt`) availability
- Configuration validity
- Optional dependencies (`gh`, `glab`)

## License

MIT
