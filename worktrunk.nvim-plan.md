# worktrunk.nvim Plugin Development Plan

A Neovim plugin that provides tight integration with the worktrunk CLI tool for git worktree management. This plugin aims to bring worktrunk's powerful worktree workflows directly into Neovim using native vim.ui interfaces.

**Target Repository:** `vinicius507/worktrunk.nvim` (to be created)

---

## 1. Features

### 1.1 User-Facing Features

| Feature | Description |
|---------|-------------|
| **Worktree List** | Browse all worktrees with metadata (branch, path, status) via vim.ui.select |
| **Worktree Switch** | Switch between worktrees with automatic directory navigation |
| **Worktree Create** | Create new worktrees from branches or PRs with interactive prompts |
| **Worktree Remove** | Safely remove worktrees with confirmation and force option |
| **Hook Integration** | Awareness of worktrunk hooks (post-create, post-switch, etc.) |
| **PR/MR Shortcuts** | Quick access to GitHub PRs (`pr:123`) and GitLab MRs (`mr:456`) |
| **Branch Navigation** | Shortcuts like `^` (default), `-` (previous), `@` (current) |
| **Worktree Status** | Visual indicators for current worktree, uncommitted changes, etc. |
| **Config Management** | View and edit worktrunk configuration from within Neovim |
| **Async Operations** | Non-blocking worktree operations with progress notifications |

### 1.2 Technical Features

| Feature | Description |
|---------|-------------|
| **Pure vim.ui** | No telescope/snacks dependencies - uses native Neovim UI |
| **Command Completion** | Full completion for :Worktree subcommands and branch names |
| **Error Handling** | Graceful handling of worktrunk CLI errors with user-friendly messages |
| **Async Execution** | vim.system() for non-blocking operations |
| **Event System** | User autocommands for hook integration (WorktreePreSwitch, WorktreePostCreate, etc.) |
| **State Management** | Cache worktree list to avoid repeated CLI calls |
| **Cross-Platform** | Support macOS, Linux, and Windows (with appropriate path handling) |

### 1.3 vim.ui Integrations

The plugin uses vim.ui for all interactive operations:

- `vim.ui.select()` - Choose from worktrees, branches, hooks
- `vim.ui.input()` - Enter branch names, search queries
- `vim.ui.confirm()` - Confirm destructive operations (remove, force)
- Custom pickers for worktree list with metadata display

---

## 2. Product Requirements

### 2.1 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-001 | Plugin must integrate with worktrunk CLI (`wt` command) | High |
| FR-002 | Support all worktrunk commands: switch, create, remove, list | High |
| FR-003 | Provide `:Worktree` command with subcommands | High |
| FR-004 | Support PR/MR shortcuts (`pr:123`, `mr:456`) | High |
| FR-005 | Support navigation shortcuts (`^`, `-`, `@`) | Medium |
| FR-006 | Display worktree metadata (path, branch, status) | High |
| FR-007 | Allow hook inspection and manual execution | Medium |
| FR-008 | Show hook execution output in Neovim | Medium |
| FR-009 | Support worktrunk configuration viewing/editing | Low |
| FR-010 | Provide visual indicators for current worktree | Medium |

### 2.2 Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-001 | No picker dependencies | Only vim.ui APIs |
| NFR-002 | Async operations | Non-blocking UI |
| NFR-003 | Error resilience | Graceful degradation |
| NFR-004 | Performance | < 100ms for list operations |
| NFR-005 | Compatibility | Neovim 0.9+ |
| NFR-006 | Code quality | LuaCATS annotations |
| NFR-007 | Documentation | Full API docs + README |

### 2.3 Integration Requirements

| ID | Requirement | Description |
|----|-------------|-------------|
| IR-001 | worktrunk CLI detection | Auto-detect `wt` in PATH |
| IR-002 | Version compatibility | Support worktrunk v0.1.0+ |
| IR-003 | Shell integration awareness | Respect worktrunk shell config |
| IR-004 | Hook system integration | Emit events for all hook types |
| IR-005 | Config file awareness | Read `.config/wt.toml` |

---

## 3. Phased Implementation Plan

### Phase 1: Core API and Commands (Week 1-2)

**Goal:** Basic functionality - can list, switch, create, and remove worktrees

**Tasks:**

1. **Project Setup**
   - Create repository structure
   - Add stylua.toml, .luacheckrc, CI
   - Set up documentation structure

2. **Core Module (`lua/worktrunk/core.lua`)**
   - CLI detection and validation
   - Base command execution (wt switch, wt list, etc.)
   - Error parsing from worktrunk output
   - Result parsing (JSON where available)

3. **Configuration (`lua/worktrunk/config.lua`)**
   - Setup function with defaults
   - Validation
   - Merging user config with defaults

4. **Commands (`lua/worktrunk/commands.lua`)**
   - Implement switch, create, remove, list
   - Basic error handling
   - Async execution wrapper

5. **Main Entry (`lua/worktrunk.lua`)**
   - Public API surface
   - require("worktrunk").setup()

**Deliverables:**
- Can switch between existing worktrees
- Can create new worktrees
- Can remove worktrees
- Can list worktrees
- Basic error messages

---

### Phase 2: UI Components (Week 3-4)

**Goal:** Rich interactive UI using vim.ui

**Tasks:**

1. **vim.ui Wrappers (`lua/worktrunk/ui.lua`)**
   - select() with formatting for worktree entries
   - input() with validation
   - confirm() with custom options

2. **Worktree Picker (`lua/worktrunk/picker.lua`)**
   - Formatted worktree list display
   - Metadata display (current, path, status)
   - Branch name filtering

3. **User Commands (`plugin/worktrunk.lua`)**
   - :Worktree command with subcommands
   - Tab completion for subcommands
   - Tab completion for branch names

4. **Notifications (`lua/worktrunk/notify.lua`)**
   - Progress indicators for long operations
   - Success/error notifications
   - Hook execution status

**Deliverables:**
- Interactive worktree picker
- Command completion working
- Visual feedback for operations
- Progress notifications

---

### Phase 3: Advanced Features (Week 5-6)

**Goal:** Hook integration, PR/MR support, events

**Tasks:**

1. **Hook System (`lua/worktrunk/hooks.lua`)**
   - Parse hook configurations
   - Execute hooks manually
   - Display hook output

2. **Events/Augroups (`lua/worktrunk/events.lua`)**
   - User autocmds for all lifecycle events
   - WorktreePreSwitch, WorktreePostSwitch
   - WorktreePostCreate, WorktreePreRemove
   - WorktreePostRemove

3. **PR/MR Integration (`lua/worktrunk/pr.lua`)**
   - Parse `pr:123` and `mr:456` syntax
   - Integration with gh/glab CLI
   - PR metadata display

4. **Status/Info (`lua/worktrunk/status.lua`)**
   - Current worktree indicator
   - Statusline integration helpers
   - Buffer-local worktree info

**Deliverables:**
- Hook execution from Neovim
- Autocommand events firing
- PR/MR shortcuts working
- Statusline helpers available

---

### Phase 4: Polish and Documentation (Week 7-8)

**Goal:** Production-ready plugin with full documentation

**Tasks:**

1. **Documentation**
   - Complete README with examples
   - Full API documentation
   - Configuration reference
   - Troubleshooting guide

2. **Testing**
   - Unit tests for core functions
   - Integration tests with mock wt CLI
   - CI pipeline with test coverage

3. **Performance Optimization**
   - Caching for worktree list
   - Debounced operations
   - Lazy loading where appropriate

4. **Final Polish**
   - Edge case handling
   - Error message improvements
   - Windows compatibility verification

**Deliverables:**
- Complete documentation
- Test suite
- Optimized performance
- Ready for release

---

## 4. Architecture & Design

### 4.1 Module Structure

```
lua/worktrunk/
├── init.lua           -- Main entry point, public API
├── config.lua         -- Configuration handling
├── core.lua           -- Core worktrunk CLI interaction
├── commands.lua       -- Command implementations
├── ui.lua             -- vim.ui wrappers
├── picker.lua         -- Interactive worktree picker
├── hooks.lua          -- Hook integration
├── events.lua         -- Autocommand events
├── pr.lua             -- PR/MR integration
├── status.lua         -- Status/info utilities
├── notify.lua         -- Notification/progress
└── utils.lua          -- Shared utilities

plugin/
└── worktrunk.lua      -- User command definitions

after/plugin/
└── worktrunk.lua      -- Optional late-loading setup
```

### 4.2 Public API Design

```lua
---@class worktrunk.Config
---@field wt_cmd string Path to wt binary (default: "wt")
---@field auto_cd boolean Auto-change directory on switch (default: true)
---@field confirm_remove boolean Confirm before removing (default: true)
---@field enable_events boolean Enable autocommands (default: true)
---@field hooks table Hook configuration overrides

---@class worktrunk.Worktree
---@field branch string Branch name
---@field path string Absolute path
---@field is_current boolean Whether this is the current worktree
---@field has_changes boolean Whether worktree has uncommitted changes
---@field pr_info table|nil PR/MR information if applicable

---Setup the plugin
---@param opts worktrunk.Config|nil
function M.setup(opts) end

---List all worktrees
---@param opts table|nil Options (force_refresh, include_remotes)
---@return worktrunk.Worktree[]
function M.list(opts) end

---Switch to a worktree
---@param branch string Branch name or shortcut (^, -, @, pr:123, etc.)
---@param opts table|nil Options (create, base, no_verify)
---@return boolean success
function M.switch(branch, opts) end

---Create a new worktree
---@param branch string Branch name
---@param base string|nil Base branch (defaults to default branch)
---@param opts table|nil Options (no_verify)
---@return boolean success
function M.create(branch, base, opts) end

---Remove a worktree
---@param branch string Branch name
---@param opts table|nil Options (force)
---@return boolean success
function M.remove(branch, opts) end

---Execute a hook manually
---@param hook_type string Hook type (pre-switch, post-create, etc.)
---@param opts table|nil Options (source: "user"|"project")
function M.run_hook(hook_type, opts) end

---Get current worktree info
---@return worktrunk.Worktree|nil
function M.current() end

---Get statusline component
---@return string
function M.statusline() end
```

### 4.3 Configuration Schema

```lua
---Default configuration
local defaults = {
  -- Path to wt binary
  wt_cmd = "wt",

  -- Automatically change directory when switching
  auto_cd = true,

  -- Confirm before removing worktrees
  confirm_remove = true,

  -- Enable autocommand events
  enable_events = true,

  -- UI options
  ui = {
    -- Show full paths or relative
    show_full_paths = false,

    -- Width of the picker (number or percentage string)
    picker_width = 60,

    -- Show preview panel in picker
    show_preview = true,
  },

  -- Hook options
  hooks = {
    -- Run hooks asynchronously
    async = true,

    -- Show hook output
    show_output = true,

    -- Timeout for hooks (seconds, 0 = no timeout)
    timeout = 0,
  },

  -- PR/MR options
  pr = {
    -- Enable PR/MR shortcuts
    enabled = true,

    -- Prefer gh or glab (auto-detect if nil)
    tool = nil, -- "gh" | "glab" | nil
  },
}
```

### 4.4 Command Structure

The `:Worktree` command follows the pattern:

```
:Worktree <subcommand> [args] [options]
```

**Subcommands:**

| Subcommand | Args | Options | Description |
|------------|------|---------|-------------|
| `list` | - | `--branches`, `--remotes` | List all worktrees |
| `switch` | `<branch>` | `--create`, `--base=<branch>`, `--no-verify` | Switch to worktree |
| `create` | `<branch>` | `--base=<branch>`, `--no-verify` | Create new worktree |
| `remove` | `<branch>` | `--force` | Remove worktree |
| `hooks` | `[type]` | `--source=<source>` | Show/run hooks |
| `current` | - | - | Show current worktree |

**Examples:**

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

" Remove forcefully
:Worktree remove old-feature --force

" Show all hooks
:Worktree hooks

" Run specific hook
:Worktree hooks post-create

" Switch to PR
:Worktree switch pr:123

" Go to previous worktree
:Worktree switch -

" Go to default branch
:Worktree switch ^
```

---

## 5. Technical Specifications

### 5.1 vim.ui Usage

All UI interactions use native vim.ui APIs:

```lua
-- Worktree selection with formatting
vim.ui.select(worktrees, {
  prompt = "Select worktree:",
  format_item = function(worktree)
    local current = worktree.is_current and "● " or "  "
    local changes = worktree.has_changes and "*" or ""
    return string.format("%s%s%s (%s)", current, worktree.branch, changes, worktree.path)
  end,
}, function(choice)
  if choice then
    require("worktrunk").switch(choice.branch)
  end
end)

-- Input with validation
vim.ui.input({
  prompt = "New branch name: ",
}, function(input)
  if input and input ~= "" then
    require("worktrunk").create(input)
  end
end)

-- Confirmation for destructive operations
vim.ui.confirm("Remove worktree '" .. branch .. "'?", function(choice)
  if choice == "y" then
    require("worktrunk").remove(branch, { force = true })
  end
end)
```

### 5.2 Command Completion

Tab completion is implemented for:

1. **Subcommands** - Complete `:Worktree <sub>`
2. **Branch names** - Complete `:Worktree switch <branch>`
3. **Hook types** - Complete `:Worktree hooks <type>`

```lua
-- Completion function structure
local function complete_worktree(arglead, cmdline, cursorpos)
  local args = vim.split(cmdline, " ", { trimempty = true })
  local cmd = args[2]

  if #args == 2 or (#args == 3 and arglead ~= "") then
    -- Complete subcommands
    return { "list", "switch", "create", "remove", "hooks", "current" }
  end

  if cmd == "switch" or cmd == "create" or cmd == "remove" then
    -- Complete branch names
    return get_branch_names()
  end

  if cmd == "hooks" then
    -- Complete hook types
    return { "pre-switch", "post-create", "post-start", "post-switch",
             "pre-commit", "pre-merge", "post-merge", "pre-remove", "post-remove" }
  end

  return {}
end
```

### 5.3 Error Handling Patterns

```lua
-- Structured error handling
local function handle_result(result, opts)
  if result.code ~= 0 then
    local error_type = parse_error(result.stderr)

    if error_type == "branch_not_found" then
      vim.notify("Branch not found: " .. opts.branch, vim.log.levels.ERROR)
      return false
    elseif error_type == "worktree_exists" then
      vim.notify("Worktree already exists for branch: " .. opts.branch, vim.log.levels.WARN)
      return false
    elseif error_type == "dirty_worktree" then
      vim.notify("Worktree has uncommitted changes. Use --force to remove.", vim.log.levels.ERROR)
      return false
    else
      vim.notify("Error: " .. result.stderr, vim.log.levels.ERROR)
      return false
    end
  end

  return true
end
```

### 5.4 Async Execution Patterns

```lua
-- Async command execution with progress
local function async_switch(branch, opts, callback)
  local notify_id = vim.notify("Switching to " .. branch .. "...", vim.log.levels.INFO, {
    title = "worktrunk",
    timeout = false,
  })

  local cmd = build_switch_cmd(branch, opts)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Switched to " .. branch, vim.log.levels.INFO, {
          title = "worktrunk",
          replace = notify_id,
        })
        if callback then callback(true) end
      else
        vim.notify("Failed to switch: " .. result.stderr, vim.log.levels.ERROR, {
          title = "worktrunk",
          replace = notify_id,
        })
        if callback then callback(false) end
      end
    end)
  end)
end
```

---

## 6. API Design Examples

### 6.1 Basic Setup

```lua
-- Minimal setup (uses all defaults)
require("worktrunk").setup()

-- Custom configuration
require("worktrunk").setup({
  auto_cd = true,
  confirm_remove = true,
  ui = {
    show_full_paths = true,
    picker_width = 80,
  },
  hooks = {
    async = true,
    show_output = true,
  },
})
```

### 6.2 Programmatic API Usage

```lua
local wt = require("worktrunk")

-- List all worktrees
local worktrees = wt.list()
for _, w in ipairs(worktrees) do
  print(w.branch .. " at " .. w.path)
end

-- Switch to a worktree
wt.switch("feature-branch")

-- Create with base branch
wt.create("hotfix", "production")

-- Create from PR
wt.switch("pr:123", { create = true })

-- Remove with force
wt.remove("old-branch", { force = true })

-- Get current worktree
local current = wt.current()
print("Currently in: " .. current.branch)

-- Statusline component
vim.o.statusline = "%f %h%m%r%=%{v:lua.require('worktrunk').statusline()} %-14.(%l,%c%V%) %P"
```

### 6.3 Hook Integration

```lua
-- Execute hooks manually
require("worktrunk").run_hook("post-create")

-- Execute only project hooks
require("worktrunk").run_hook("post-create", { source = "project" })

-- Using autocommands
vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePostCreate",
  callback = function(args)
    local branch = args.data.branch
    local path = args.data.path
    vim.notify("Created worktree for " .. branch .. " at " .. path)
  end,
})
```

### 6.4 Advanced Usage

```lua
-- Custom picker with filtering
local wt = require("worktrunk")
local worktrees = wt.list({ include_remotes = true })

-- Filter to only feature branches
local features = vim.tbl_filter(function(w)
  return vim.startswith(w.branch, "feature/")
end, worktrees)

-- Interactive selection
vim.ui.select(features, {
  prompt = "Select feature branch:",
  format_item = function(w)
    return w.branch .. " (" .. vim.fn.fnamemodify(w.path, ":~") .. ")"
  end,
}, function(choice)
  if choice then
    wt.switch(choice.branch)
  end
end)
```

---

## 7. Command Design

### 7.1 Command Definitions

```lua
-- plugin/worktrunk.lua
vim.api.nvim_create_user_command("Worktree", function(opts)
  require("worktrunk.commands").execute(opts.args)
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    return require("worktrunk.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "Worktrunk worktree management",
})
```

### 7.2 Subcommand Handlers

```lua
-- lua/worktrunk/commands.lua
local M = {}

local subcommands = {
  list = function(args)
    local opts = parse_list_args(args)
    local worktrees = require("worktrunk").list(opts)
    require("worktrunk.picker").show(worktrees)
  end,

  switch = function(args)
    local branch, opts = parse_switch_args(args)
    if not branch then
      -- Interactive mode
      local worktrees = require("worktrunk").list()
      require("worktrunk.picker").show(worktrees, function(choice)
        if choice then
          require("worktrunk").switch(choice.branch, opts)
        end
      end)
    else
      require("worktrunk").switch(branch, opts)
    end
  end,

  create = function(args)
    local branch, base, opts = parse_create_args(args)
    if not branch then
      vim.ui.input({ prompt = "Branch name: " }, function(input)
        if input then
          require("worktrunk").create(input, base, opts)
        end
      end)
    else
      require("worktrunk").create(branch, base, opts)
    end
  end,

  remove = function(args)
    local branch, opts = parse_remove_args(args)
    if not branch then
      local worktrees = require("worktrunk").list()
      require("worktrunk.picker").show(worktrees, function(choice)
        if choice then
          require("worktrunk").remove(choice.branch, opts)
        end
      end)
    else
      require("worktrunk").remove(branch, opts)
    end
  end,

  hooks = function(args)
    local hook_type = args[1]
    if hook_type then
      require("worktrunk").run_hook(hook_type)
    else
      -- Show hooks configuration
      require("worktrunk.hooks").show_config()
    end
  end,

  current = function()
    local current = require("worktrunk").current()
    if current then
      print("Current: " .. current.branch .. " at " .. current.path)
    else
      print("Not in a worktree")
    end
  end,
}

function M.execute(args_str)
  local args = vim.split(args_str, " ", { trimempty = true })
  local subcmd = table.remove(args, 1)

  if not subcmd or subcmd == "" then
    -- Default to list
    subcommands.list(args)
    return
  end

  local handler = subcommands[subcmd]
  if handler then
    handler(args)
  else
    vim.notify("Unknown subcommand: " .. subcmd, vim.log.levels.ERROR)
  end
end

return M
```

### 7.3 Command Completion Implementation

```lua
function M.complete(arglead, cmdline, cursorpos)
  local args = vim.split(cmdline, " ", { trimempty = true })
  table.remove(args, 1) -- Remove "Worktree"

  if #args == 0 or (#args == 1 and arglead ~= "" and not cmdline:sub(cursorpos, cursorpos):match("%s")) then
    -- Complete subcommand
    local subcmds = { "list", "switch", "create", "remove", "hooks", "current" }
    return vim.tbl_filter(function(cmd)
      return vim.startswith(cmd, arglead)
    end, subcmds)
  end

  local subcmd = args[1]

  if subcmd == "switch" or subcmd == "create" or subcmd == "remove" then
    return complete_branches(arglead)
  end

  if subcmd == "hooks" then
    return complete_hooks(arglead)
  end

  if subcmd == "switch" or subcmd == "create" then
    -- Complete options
    if vim.startswith(arglead, "--") then
      return { "--create", "--base=", "--no-verify", "--force" }
    end
    if vim.startswith(arglead, "-") then
      return { "-c", "-b", "-f" }
    end
  end

  return {}
end
```

---

## 8. Suggested Keymaps

While keymaps are optional and should be configured by the user, here are suggested mappings under the `<leader>gw` prefix:

```lua
-- Suggested keymaps (user-configured)
local function setup_keymaps()
  local wk = require("which-key")

  wk.register({
    ["<leader>g"] = {
      name = "git",
      w = {
        name = "worktree",
        l = { "<cmd>Worktree list<cr>", "List worktrees" },
        s = { "<cmd>Worktree switch<cr>", "Switch worktree" },
        c = { "<cmd>Worktree create<cr>", "Create worktree" },
        d = { "<cmd>Worktree remove<cr>", "Delete worktree" },
        p = { "<cmd>Worktree switch pr:", "Switch to PR (prompt)" },
        ["-"] = { "<cmd>Worktree switch -<cr>", "Previous worktree" },
        ["^"] = { "<cmd>Worktree switch ^<cr>", "Default branch" },
        h = { "<cmd>Worktree hooks<cr>", "Show hooks" },
      },
    },
  })
end
```

### Alternative Minimal Keymaps

```lua
-- Without which-key
vim.keymap.set("n", "<leader>gwl", "<cmd>Worktree list<cr>", { desc = "List worktrees" })
vim.keymap.set("n", "<leader>gws", "<cmd>Worktree switch<cr>", { desc = "Switch worktree" })
vim.keymap.set("n", "<leader>gwc", "<cmd>Worktree create<cr>", { desc = "Create worktree" })
vim.keymap.set("n", "<leader>gwd", "<cmd>Worktree remove<cr>", { desc = "Delete worktree" })
```

---

## 9. Event System

### 9.1 Autocommand Events

The plugin emits User autocommands for integration:

| Event | When | Data |
|-------|------|------|
| `WorktreePreSwitch` | Before switching | `{ from_branch, to_branch }` |
| `WorktreePostSwitch` | After switching | `{ from_branch, to_branch, path }` |
| `WorktreePostCreate` | After creating | `{ branch, path, base }` |
| `WorktreePreRemove` | Before removing | `{ branch, path }` |
| `WorktreePostRemove` | After removing | `{ branch, path }` |

### 9.2 Usage Examples

```lua
-- Run custom action after switching
vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePostSwitch",
  callback = function(args)
    local data = args.data
    print("Switched from " .. data.from_branch .. " to " .. data.to_branch)

    -- Reload LSP for new project root
    vim.cmd("LspRestart")
  end,
})

-- Backup before removing
vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePreRemove",
  callback = function(args)
    local data = args.data
    local backup_dir = vim.fn.expand("~/.worktree-backups/")
    vim.fn.system({"mkdir", "-p", backup_dir})
    vim.fn.system({"tar", "-czf", backup_dir .. data.branch .. ".tar.gz", "-C", data.path, "."})
  end,
})
```

---

## 10. Integration with Existing Tools

### 10.1 LSP Integration

When switching worktrees, the LSP should be notified of the new workspace:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePostSwitch",
  callback = function()
    -- Restart LSP clients for the new workspace
    vim.cmd("LspRestart")
  end,
})
```

### 10.2 Session Management

```lua
-- Auto-save and restore sessions per worktree
vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePreSwitch",
  callback = function()
    -- Save current session
    require("persistence").save()
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "WorktreePostSwitch",
  callback = function()
    -- Load session for new worktree
    require("persistence").load()
  end,
})
```

### 10.3 Statusline Integration

```lua
-- Simple component for lualine or similar
local function worktree_component()
  local current = require("worktrunk").current()
  if current then
    return " " .. current.branch
  end
  return ""
end

-- lualine setup example
require("lualine").setup({
  sections = {
    lualine_b = { worktree_component, "branch", "diff" },
  },
})
```

---

## 11. Error Scenarios & Handling

| Scenario | Error | Handling |
|----------|-------|----------|
| wt not found | Binary not in PATH | Notify user to install worktrunk |
| Branch doesn't exist | "branch not found" | Suggest using --create flag |
| Worktree exists | "worktree already exists" | Offer to switch instead |
| Dirty worktree | "worktree has uncommitted changes" | Require --force for removal |
| Path occupied | "path already exists" | Suggest --clobber or manual cleanup |
| Hook failure | "hook exited with code X" | Show output, allow retry/skip |
| Network issues | "failed to fetch PR" | Show error, suggest manual retry |
| Invalid PR number | "PR not found" | Prompt for correct number |

---

## 12. Development Guidelines

### 12.1 Code Style

- 2-space indentation
- snake_case for functions and variables
- PascalCase for classes/types
- Full EmmyLua annotations
- No trailing semicolons

### 12.2 Testing Strategy

```lua
-- tests/core_spec.lua
describe("worktrunk.core", function()
  it("parses worktree list output", function()
    local output = [[
main ~/projects/myrepo
feature-branch ~/projects/myrepo.feature-branch
]]
    local worktrees = core.parse_list(output)
    assert.equals(2, #worktrees)
    assert.equals("main", worktrees[1].branch)
  end)
end)
```

### 12.3 Documentation Standards

- README with installation and quickstart
- Full API documentation in doc/worktrunk.txt
- Inline code comments
- Example configurations

---

## 13. Future Enhancements

Potential features for future versions:

1. **Fuzzy finder integration** - Optional telescope/snacks extensions
2. **Git graph view** - Visual branch/worktree relationship
3. **Conflict resolution** - Built-in merge conflict handling
4. **Template support** - Worktrunk template variable completion
5. **CI status display** - Show CI status in worktree list
6. **Branch comparison** - Diff between worktrees
7. **Bulk operations** - Remove multiple worktrees at once
8. **Tmux integration** - Automatic tmux session management

---

## 14. References

### 14.1 Worktrunk Documentation

- [worktrunk.dev](https://worktrunk.dev)
- `wt switch` - Switch to a worktree; create if needed
- `wt remove` - Remove a worktree
- `wt list` - List worktrees and branches
- `wt hook` - Run configured hooks
- `wt config` - Manage user & project configs

### 14.2 Neovim Resources

- `:help vim.ui`
- `:help vim.system()`
- `:help api-autocmd`
- `:help lua-guide`

### 14.3 Similar Plugins

- `vim-fugitive` - Git integration patterns
- `git-worktree.nvim` - Alternative worktree plugin (to improve upon)
- `neogit` - Magit-inspired git interface

---

## 15. Success Criteria

This plan is complete when:

- [x] All features are documented
- [x] API design is finalized
- [x] Implementation phases are defined
- [x] Architecture decisions are recorded
- [x] Technical specifications are detailed
- [x] Command structure is designed
- [x] Keymap suggestions are provided
- [x] Event system is specified

---

**Document Version:** 1.1  
**Last Updated:** 2025-03-26  
**Status:** Ready for Implementation

---

## 16. Testing Strategy

Following nvim-best-practices recommendations, we use **busted** instead of plenary.nvim for testing.

### 16.1 Test Framework: Busted

**Why busted:**
- De facto standard in Lua community (rspec-like API)
- Better reproducibility with luarocks dependency management
- Can pin dependencies to avoid "works on my machine" issues
- Package managers can run test suites
- More powerful assertions than plenary's limited luassert subset

### 16.2 Test Configuration

**.busted** file:
```lua
return {
  _all = {
    lua = "./scripts/nlua",
    coverage = true,
    lpath = "lua/?.lua;lua/?/init.lua;spec/?.lua",
  },
  default = {
    verbose = true,
    ROOT = { "spec/" },
  },
}
```

**scripts/nlua** (Neovim as Lua interpreter):
```bash
#!/bin/bash
exec nvim -u NONE -l "$@"
```

### 16.3 Test Directory Structure

```
spec/
├── core_spec.lua          -- Core CLI interaction tests
├── config_spec.lua        -- Configuration tests
├── commands_spec.lua      -- Command tests
├── ui_spec.lua            -- vim.ui wrapper tests
├── picker_spec.lua        -- Picker tests
├── hooks_spec.lua         -- Hook integration tests
├── events_spec.lua        -- Event system tests
└── fixtures/
    ├── mock_wt_output.txt
    └── test_repo/
```

### 16.4 Test Examples

```lua
-- spec/core_spec.lua
describe("worktrunk.core", function()
  local core
  
  before_each(function()
    core = require("worktrunk.core")
  end)
  
  describe("parse_list", function()
    it("should parse worktree list output", function()
      local output = [[
main ~/projects/myrepo
feature-branch ~/projects/myrepo.feature-branch
]]
      local worktrees = core.parse_list(output)
      
      assert.are.equal(2, #worktrees)
      assert.are.equal("main", worktrees[1].branch)
      assert.are.equal("~/projects/myrepo", worktrees[1].path)
    end)
    
    it("should handle empty output", function()
      local worktrees = core.parse_list("")
      assert.are.equal(0, #worktrees)
    end)
  end)
  
  describe("parse_error", function()
    it("should identify branch_not_found error", function()
      local stderr = "Error: branch 'nonexistent' not found"
      local error_type = core.parse_error(stderr)
      
      assert.are.equal("branch_not_found", error_type)
    end)
    
    it("should identify worktree_exists error", function()
      local stderr = "Error: worktree already exists for branch 'main'"
      local error_type = core.parse_error(stderr)
      
      assert.are.equal("worktree_exists", error_type)
    end)
  end)
end)
```

```lua
-- spec/config_spec.lua
describe("worktrunk.config", function()
  local config
  
  before_each(function()
    -- Reset module state
    package.loaded["worktrunk.config"] = nil
    config = require("worktrunk.config")
  end)
  
  describe("setup", function()
    it("should merge user config with defaults", function()
      config.setup({ auto_cd = false })
      local cfg = config.get()
      
      assert.are.equal(false, cfg.auto_cd)
      assert.are.equal(true, cfg.confirm_remove) -- default
    end)
    
    it("should validate wt_cmd is a string", function()
      local ok, err = pcall(function()
        config.setup({ wt_cmd = 123 })
      end)
      
      assert.is_false(ok)
      assert.is_truthy(err:match("wt_cmd"))
    end)
    
    it("should support vim.g.worktrunk configuration", function()
      vim.g.worktrunk = { auto_cd = false }
      config.setup()
      local cfg = config.get()
      
      assert.are.equal(false, cfg.auto_cd)
      vim.g.worktrunk = nil
    end)
  end)
end)
```

### 16.5 Running Tests Locally

```bash
# Run all tests
make test

# Run specific test file
make test-file file=spec/core_spec.lua

# Run with coverage
make test-coverage

# Run in current Neovim (for debugging)
make test-debug
```

### 16.6 Mocking External Dependencies

```lua
-- spec/helpers.lua
local M = {}

function M.mock_vim_system(result)
  local original = vim.system
  vim.system = function(cmd, opts, callback)
    if callback then
      callback(result)
    end
    return {
      wait = function() return result end,
    }
  end
  return function()
    vim.system = original
  end
end

function M.mock_wt_list_output(worktrees)
  local stdout = table.concat(
    vim.tbl_map(function(w) 
      return w.branch .. " " .. w.path 
    end, worktrees),
    "\n"
  )
  return {
    code = 0,
    stdout = stdout,
    stderr = "",
  }
end

return M
```

---

## 17. GitHub Actions Workflows

### 17.1 CI Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:

jobs:
  test:
    name: Test (${{ matrix.os }}, Neovim ${{ matrix.nvim-version }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        nvim-version: [stable, nightly]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run tests
        uses: nvim-neorocks/nvim-busted-action@v1
        with:
          nvim_version: ${{ matrix.nvim-version }}

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Type check
        uses: stevearc/nvim-typecheck-action@v2
        with:
          path: lua
          level: Information
          nvim-version: stable

  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install luacheck
        run: |
          sudo apt-get update
          sudo apt-get install -y lua-check

      - name: Run luacheck
        run: luacheck lua/

  format:
    name: Format Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install stylua
        uses: baptiste0928/cargo-install@v3
        with:
          crate: stylua
          version: "0.20.0"

      - name: Check formatting
        run: stylua --check lua/ spec/
```

### 17.2 Release Workflow

**.github/workflows/release.yml:**
```yaml
name: Release

on:
  push:
    branches: [main, master]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    name: Release Please
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          release-type: simple
          package-name: worktrunk.nvim

      - name: Checkout
        if: ${{ steps.release.outputs.release_created }}
        uses: actions/checkout@v4

      - name: Publish to luarocks
        if: ${{ steps.release.outputs.release_created }}
        uses: nvim-neorocks/luarocks-tag-release@v5
        with:
          name: worktrunk.nvim
          version: ${{ steps.release.outputs.major }}.${{ steps.release.outputs.minor }}.${{ steps.release.outputs.patch }}
          labels: |
            neovim
            git
            worktree
```

### 17.3 Nightly Check Workflow

**.github/workflows/nightly-check.yml:**
```yaml
name: Nightly Check

on:
  schedule:
    - cron: "0 0 * * *" # Daily at midnight
  workflow_dispatch:

jobs:
  test-nightly:
    name: Test Against Neovim Nightly
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run tests
        uses: nvim-neorocks/nvim-busted-action@v1
        with:
          nvim_version: nightly
```

---

## 18. Health Checks

Create `lua/worktrunk/health.lua` for `:checkhealth worktrunk` integration.

### 18.1 Health Check Implementation

```lua
---@module "worktrunk.health"
local M = {}

---@class worktrunk.HealthCheck
---@field name string
---@field status "ok"|"warn"|"error"
---@field message string

function M.check()
  vim.health.start("worktrunk.nvim")

  -- Check worktrunk CLI
  M._check_cli()

  -- Check configuration
  M._check_config()

  -- Check optional dependencies
  M._check_optional_deps()
end

function M._check_cli()
  if vim.fn.executable("wt") == 0 then
    vim.health.error(
      "worktrunk CLI (wt) not found in PATH",
      { "Install from: https://worktrunk.dev" }
    )
    return
  end

  local result = vim.system({ "wt", "--version" }):wait()
  if result.code ~= 0 then
    vim.health.warn(
      "worktrunk CLI found but version check failed",
      { "Ensure wt is properly installed" }
    )
    return
  end

  local version = result.stdout:gsub("%s+$", "")
  vim.health.ok("worktrunk CLI found: " .. version)
end

function M._check_config()
  local ok, config = pcall(require, "worktrunk.config")
  if not ok then
    vim.health.warn("Configuration module not loaded (will use defaults)")
    return
  end

  local cfg = config.get()
  if not cfg then
    vim.health.warn("Configuration not initialized (will use defaults)")
    return
  end

  vim.health.ok("Configuration loaded")

  -- Check for unknown fields (typos)
  local known_fields = {
    "wt_cmd", "auto_cd", "confirm_remove", "enable_events",
    "ui", "hooks", "pr"
  }
  local unknown_fields = {}
  for k, _ in pairs(cfg) do
    if not vim.tbl_contains(known_fields, k) then
      table.insert(unknown_fields, k)
    end
  end

  if #unknown_fields > 0 then
    vim.health.warn(
      "Unknown configuration fields (possible typos): " .. table.concat(unknown_fields, ", "),
      { "Check documentation for valid configuration options" }
    )
  end
end

function M._check_optional_deps()
  -- Check for gh CLI (GitHub PR support)
  if vim.fn.executable("gh") == 1 then
    vim.health.ok("GitHub CLI (gh) found - PR shortcuts available")
  else
    vim.health.info("GitHub CLI (gh) not found - PR shortcuts will not work")
  end

  -- Check for glab CLI (GitLab MR support)
  if vim.fn.executable("glab") == 1 then
    vim.health.ok("GitLab CLI (glab) found - MR shortcuts available")
  else
    vim.health.info("GitLab CLI (glab) not found - MR shortcuts will not work")
  end
end

return M
```

---

## 19. Auto-Initialization & Lazy Loading

### 19.1 Principles

Following nvim-best-practices:
- **DON'T** force users to call `setup()`
- **DO** auto-initialize on first use
- **DO** separate configuration from initialization
- **DO** support `vim.g.worktrunk` for configuration

### 19.2 Implementation

**lua/worktrunk/init.lua:**
```lua
---@module "worktrunk"
local M = {}

local initialized = false

---@return boolean
function M._ensure_initialized()
  if initialized then
    return true
  end

  -- Support vim.g.worktrunk for configuration
  local opts = vim.g.worktrunk or {}
  M.setup(opts)
  return true
end

---Setup the plugin
---@param opts worktrunk.UserConfig|nil
function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}
  
  -- Validate and merge configuration
  local config = require("worktrunk.config")
  config.setup(opts)
  
  -- Initialize event system
  require("worktrunk.events").setup()
  
  initialized = true
end

-- ... rest of public API (list, switch, create, remove, etc.) ...

return M
```

**plugin/worktrunk.lua:**
```lua
-- Commands defer require calls for lazy loading
vim.api.nvim_create_user_command("Worktree", function(opts)
  -- Auto-initialize on first use
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute(opts.args)
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    -- Ensure initialized before completing
    require("worktrunk")._ensure_initialized()
    return require("worktrunk.commands").complete(arglead, cmdline, cursorpos)
  end,
  desc = "Worktrunk worktree management",
})

-- Define <Plug> mappings for user keymaps
vim.keymap.set("n", "<Plug>(WorktreeList)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("list")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeSwitch)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("switch")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeCreate)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("create")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeRemove)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("remove")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeHooks)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("hooks")
end, { silent = true })

vim.keymap.set("n", "<Plug>(WorktreeCurrent)", function()
  require("worktrunk")._ensure_initialized()
  require("worktrunk.commands").execute("current")
end, { silent = true })
```

### 19.3 Configuration via vim.g

Users can configure without calling setup:

```lua
-- init.lua or vimrc
vim.g.worktrunk = {
  auto_cd = false,
  confirm_remove = false,
  ui = {
    show_full_paths = true,
  },
}
```

---

## 20. Configuration Best Practices

### 20.1 Type Definitions

**lua/worktrunk/config/meta.lua:**
```lua
---User-facing configuration (all fields optional)
---@class (partial) worktrunk.UserConfig
---@field wt_cmd? string Path to wt binary (default: "wt")
---@field auto_cd? boolean Auto-change directory on switch (default: true)
---@field confirm_remove? boolean Confirm before removing (default: true)
---@field enable_events? boolean Enable autocommands (default: true)
---@field ui? worktrunk.UserUIConfig UI options
---@field hooks? worktrunk.UserHooksConfig Hook options
---@field pr? worktrunk.UserPRConfig PR/MR options

---@class (partial) worktrunk.UserUIConfig
---@field show_full_paths? boolean Show full paths or relative (default: false)
---@field picker_width? number|string Width of picker (default: 60)
---@field show_preview? boolean Show preview panel (default: true)

---@class (partial) worktrunk.UserHooksConfig
---@field async? boolean Run hooks asynchronously (default: true)
---@field show_output? boolean Show hook output (default: true)
---@field timeout? number Timeout in seconds, 0 = no timeout (default: 0)

---@class (partial) worktrunk.UserPRConfig
---@field enabled? boolean Enable PR/MR shortcuts (default: true)
---@field tool? "gh"|"glab"|nil Prefer gh or glab (auto-detect if nil)

---Support configuration via vim.g
---@type worktrunk.UserConfig|fun():worktrunk.UserConfig|nil
vim.g.worktrunk = vim.g.worktrunk
```

**lua/worktrunk/config/internal.lua:**
```lua
---Internal configuration (all fields required)
---@class worktrunk.Config
---@field wt_cmd string
---@field auto_cd boolean
---@field confirm_remove boolean
---@field enable_events boolean
---@field ui worktrunk.UIConfig
---@field hooks worktrunk.HooksConfig
---@field pr worktrunk.PRConfig

---@class worktrunk.UIConfig
---@field show_full_paths boolean
---@field picker_width number|string
---@field show_preview boolean

---@class worktrunk.HooksConfig
---@field async boolean
---@field show_output boolean
---@field timeout number

---@class worktrunk.PRConfig
---@field enabled boolean
---@field tool "gh"|"glab"|nil
```

### 20.2 Validation

```lua
---@param path string
---@param tbl table
---@return boolean ok
---@return string|nil err
local function validate_path(path, tbl)
  local ok, err = pcall(vim.validate, tbl)
  return ok, err and path .. "." .. err
end

---Validate configuration
---@param cfg worktrunk.Config
---@return boolean ok
---@return string|nil err
function M.validate(cfg)
  -- Validate top-level fields
  local ok, err = validate_path("vim.g.worktrunk", {
    wt_cmd = { cfg.wt_cmd, "string" },
    auto_cd = { cfg.auto_cd, "boolean" },
    confirm_remove = { cfg.confirm_remove, "boolean" },
    enable_events = { cfg.enable_events, "boolean" },
  })
  if not ok then
    return false, err
  end

  -- Validate nested ui fields
  ok, err = validate_path("vim.g.worktrunk.ui", {
    show_full_paths = { cfg.ui.show_full_paths, "boolean" },
    show_preview = { cfg.ui.show_preview, "boolean" },
  })
  if not ok then
    return false, err
  end

  return true
end
```

---

## 21. Updated Keymap Suggestions

### 21.1 Using <Plug> Mappings

**Recommended approach using <Plug>:**
```lua
-- User's configuration (init.lua)
-- These work even if the plugin is not installed

-- Basic worktree mappings
vim.keymap.set("n", "<leader>gwl", "<Plug>(WorktreeList)", { desc = "List worktrees" })
vim.keymap.set("n", "<leader>gws", "<Plug>(WorktreeSwitch)", { desc = "Switch worktree" })
vim.keymap.set("n", "<leader>gwc", "<Plug>(WorktreeCreate)", { desc = "Create worktree" })
vim.keymap.set("n", "<leader>gwd", "<Plug>(WorktreeRemove)", { desc = "Delete worktree" })
vim.keymap.set("n", "<leader>gwh", "<Plug>(WorktreeHooks)", { desc = "Show hooks" })

-- Quick navigation
vim.keymap.set("n", "<leader>gw-", "<cmd>Worktree switch -<cr>", { desc = "Previous worktree" })
vim.keymap.set("n", "<leader>gw^", "<cmd>Worktree switch ^<cr>", { desc = "Default branch" })
```

### 21.2 Using Lua API

**Alternative for programmatic access:**
```lua
local wt = require("worktrunk")

-- Custom picker with filtering
vim.keymap.set("n", "<leader>gwf", function()
  local worktrees = wt.list()
  local features = vim.tbl_filter(function(w)
    return vim.startswith(w.branch, "feature/")
  end, worktrees)
  
  vim.ui.select(features, {
    prompt = "Select feature branch:",
    format_item = function(w)
      return w.branch
    end,
  }, function(choice)
    if choice then
      wt.switch(choice.branch)
    end
  end)
end, { desc = "Switch to feature branch" })
```

---

## 22. Updated Project Structure

```
worktrunk.nvim/
├── lua/
│   └── worktrunk/
│       ├── init.lua           -- Main entry, public API, auto-init
│       ├── config/
│       │   ├── meta.lua       -- User-facing config types (partial)
│       │   ├── internal.lua   -- Internal config types
│       │   └── init.lua       -- Config merging and validation
│       ├── core.lua           -- Core worktrunk CLI interaction
│       ├── commands.lua       -- Command implementations
│       ├── health.lua         -- :checkhealth integration
│       ├── ui.lua             -- vim.ui wrappers
│       ├── picker.lua         -- Interactive worktree picker
│       ├── hooks.lua          -- Hook integration
│       ├── events.lua         -- Autocommand events
│       ├── pr.lua             -- PR/MR integration
│       ├── status.lua         -- Status/info utilities
│       ├── notify.lua         -- Notification/progress
│       └── utils.lua          -- Shared utilities
│
├── plugin/
│   └── worktrunk.lua          -- User commands, <Plug> mappings (lazy)
│
├── spec/                      -- Tests (busted)
│   ├── core_spec.lua
│   ├── config_spec.lua
│   ├── commands_spec.lua
│   ├── ui_spec.lua
│   ├── helpers.lua            -- Test utilities
│   └── fixtures/
│       ├── mock_wt_output.txt
│       └── test_repo/
│
├── doc/
│   └── worktrunk.txt          -- vimdoc documentation
│
├── scripts/
│   ├── nlua                   -- Neovim as Lua interpreter
│   └── generate-vimdoc.sh     -- Generate doc from README
│
├── .github/
│   └── workflows/
│       ├── ci.yml             -- Tests, typecheck, lint, format
│       ├── release.yml        -- release-please + luarocks
│       └── nightly-check.yml  -- Daily test against nightly
│
├── .luarc.json                -- Lua 5.1, type config
├── .busted                    -- busted test config
├── .luacheckrc                -- luacheck linting rules
├── .stylua.toml               -- stylua formatting
├── Makefile                   -- Test commands
├── README.md                  -- Main documentation
├── LICENSE                    -- MIT License
└── CHANGELOG.md               -- Auto-generated by release-please
```

---

## 23. Compliance Checklist

This section tracks compliance with nvim-best-practices:

### Type Safety
- [x] Uses LuaCATS annotations (@class, @field)
- [x] Uses `(partial)` attribute for user config
- [x] Splits user vs internal config types
- [x] Includes .luarc.json with Lua 5.1
- [x] Validates config with vim.validate()

### User Commands
- [x] Uses scoped command (`:Worktree` with subcommands)
- [x] Provides subcommand completions
- [x] Provides argument completions
- [x] No namespace pollution

### Keymaps
- [x] Provides `<Plug>` mappings
- [x] No auto-keymaps
- [x] Documents Lua API for keymaps
- [x] No which-key dependency in examples

### Initialization
- [x] Works without calling setup()
- [x] Auto-initializes on first use
- [x] Separates config from initialization
- [x] Supports vim.g configuration

### Lazy Loading
- [x] Commands defer requires
- [x] No eager requires in plugin/
- [x] Does not rely on plugin manager

### Configuration
- [x] Uses optional fields (?) for user config
- [x] Uses (partial) class attribute
- [x] Validates with vim.validate()
- [x] Supports vim.g.worktrunk

### Health Checks
- [x] Provides lua/worktrunk/health.lua
- [x] Checks external dependencies (wt CLI)
- [x] Validates configuration
- [x] Checks optional deps (gh, glab)

### Testing
- [x] Uses busted (not plenary)
- [x] Uses nvim-busted-action in CI
- [x] Has spec/ directory
- [x] Includes .busted config
- [x] Tests on stable and nightly
- [x] Tests on multi-OS

### Versioning
- [x] Uses SemVer (not 0ver)
- [x] Uses release-please-action
- [x] Documents vim.deprecate() usage

### Documentation
- [x] Provides vimdoc (doc/worktrunk.txt)
- [x] Uses generation tool (panvimdoc/vimCATS)
- [x] Has README with examples
- [x] Full API documentation

### Lua Compatibility
- [x] Uses Lua 5.1 API
- [x] .luarc.json specifies Lua 5.1
- [x] No LuaJIT extensions

### GitHub Actions
- [x] CI with busted testing
- [x] Type checking (nvim-typecheck-action)
- [x] Linting (luacheck)
- [x] Formatting (stylua)
- [x] Multi-OS testing
- [x] Multi-version testing (stable, nightly)
- [x] Release automation (release-please)
- [x] Luarocks publishing

---

## 24. Best Practices References

### 24.1 Key Resources

- [nvim-best-practices](https://github.com/lumen-oss/nvim-best-practices) - Main guide
- [nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template) - Example template
- [ci-template.nvim](https://github.com/lukas-reineke/ci-template.nvim) - CI template
- [Testing Neovim plugins with Busted](https://hiphish.github.io/blog/2024/01/29/testing-neovim-plugins-with-busted/) - Testing guide

### 24.2 Tools Used

| Tool | Purpose |
|------|---------|
| busted | Testing framework |
| nvim-busted-action | GitHub Action for testing |
| nvim-typecheck-action | Type checking |
| luacheck | Linting |
| stylua | Formatting |
| release-please-action | Automated releases |
| luarocks-tag-release | Luarocks publishing |
| panvimdoc | vimdoc generation |

---

**Document Version:** 1.1  
**Last Updated:** 2025-03-26  
**Status:** Ready for Implementation - Updated with Best Practices
