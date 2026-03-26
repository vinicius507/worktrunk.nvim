---@module "worktrunk.ui.picker"
---Picker wrappers for vim.ui.select

local M = {}

---@class worktrunk.PickerOpts
---@field prompt string
---@field format_item fun(item: any): string
---@field kind string|nil

---Show a picker for worktrees
---@param worktrees worktrunk.Worktree[]
---@param opts worktrunk.PickerOpts
---@param on_select fun(choice: worktrunk.Worktree|nil)
function M.worktrees(worktrees, opts, on_select)
  local config = require("worktrunk.config.internal").get()

  opts = opts or {}
  local prompt = opts.prompt or "Select worktree:"
  local format_item = opts.format_item
    or function(worktree)
      local current = require("worktrunk.api.cli").current()
      local marker = current and current.branch == worktree.branch and "● " or "  "
      return marker .. worktree.branch
    end

  vim.ui.select(worktrees, {
    prompt = prompt,
    format_item = format_item,
    kind = opts.kind or "worktrunk.worktree",
  }, function(choice)
    on_select(choice)
  end)
end

---Show a confirmation picker
---@param message string
---@param on_confirm fun(confirmed: boolean)
function M.confirm(message, on_confirm)
  vim.ui.select({ "Yes", "No" }, {
    prompt = message,
  }, function(choice)
    on_confirm(choice == "Yes")
  end)
end

---Show a picker with custom items
---@generic T
---@param items T[]
---@param opts worktrunk.PickerOpts
---@param on_select fun(choice: T|nil)
function M.select(items, opts, on_select)
  opts = opts or {}

  vim.ui.select(items, {
    prompt = opts.prompt or "Select:",
    format_item = opts.format_item or tostring,
    kind = opts.kind,
  }, function(choice)
    on_select(choice)
  end)
end

return M
