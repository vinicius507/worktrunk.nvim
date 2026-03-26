---@module "worktrunk.config.meta"
---Type definitions for worktrunk.nvim configuration

---@class worktrunk.Commit
---@field sha string
---@field short_sha string
---@field message string
---@field timestamp number

---@class worktrunk.WorkingTree
---@field staged boolean
---@field modified boolean
---@field untracked boolean
---@field renamed boolean
---@field deleted boolean
---@field diff { added: number, deleted: number }

---@class worktrunk.Worktree
---@field branch string
---@field path string
---@field kind string "worktree" or "branch"
---@field commit worktrunk.Commit|nil
---@field working_tree worktrunk.WorkingTree|nil
---@field main_state string|nil
---@field is_main boolean
---@field is_current boolean
---@field is_previous boolean
---@field symbols string

---@class worktrunk.UIConfigMeta
---@field show_full_paths boolean|nil
---@field picker_width number|string|nil
---@field show_preview boolean|nil

---@class worktrunk.HooksConfigMeta
---@field async boolean|nil
---@field show_output boolean|nil
---@field timeout number|nil

---@class worktrunk.PRConfigMeta
---@field enabled boolean|nil
---@field tool "gh"|"glab"|nil

---@class worktrunk.ConfigMeta
---@field wt_cmd string|nil
---@field auto_cd boolean|nil
---@field confirm_remove boolean|nil
---@field enable_events boolean|nil
---@field ui worktrunk.UIConfigMeta|nil
---@field hooks worktrunk.HooksConfigMeta|nil
---@field pr worktrunk.PRConfigMeta|nil

local M = {}

return M
