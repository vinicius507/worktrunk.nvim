---@module "worktrunk.config.internal"
---Internal configuration with guaranteed values

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

---@class worktrunk.Config
---@field wt_cmd string
---@field auto_cd boolean
---@field confirm_remove boolean
---@field enable_events boolean
---@field ui worktrunk.UIConfig
---@field hooks worktrunk.HooksConfig
---@field pr worktrunk.PRConfig

local M = {}

---@type worktrunk.Config|nil
local config = nil

---Default configuration values
---@type worktrunk.Config
M.defaults = {
  wt_cmd = "wt",
  auto_cd = true,
  confirm_remove = true,
  enable_events = true,
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
    tool = nil,
  },
}

---Deep merge tables
---@param t1 table
---@param t2 table
---@return table
local function merge(t1, t2)
  return vim.tbl_deep_extend("force", t1, t2)
end

---Setup the configuration
---@param opts worktrunk.ConfigMeta|nil
function M.setup(opts)
  if config then
    return
  end

  opts = opts or {}

  -- Support vim.g.worktrunk configuration
  if vim.g.worktrunk then
    opts = merge(opts, vim.g.worktrunk)
  end

  config = merge(M.defaults, opts)
end

---Get the current configuration
---@return worktrunk.Config
function M.get()
  if not config then
    M.setup()
  end
  return config
end

---Reset configuration (for testing)
function M.reset()
  config = nil
end

return M
