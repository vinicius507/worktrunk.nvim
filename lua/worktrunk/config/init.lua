---@module "worktrunk.config"
local M = {}

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

---@type worktrunk.Config|nil
local config = nil

---Default configuration
---@type worktrunk.Config
local defaults = {
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

---Validate configuration
---@param cfg worktrunk.Config
---@return boolean ok
---@return string|nil err
local function validate(cfg)
  local ok, err = pcall(vim.validate, {
    wt_cmd = { cfg.wt_cmd, "string" },
    auto_cd = { cfg.auto_cd, "boolean" },
    confirm_remove = { cfg.confirm_remove, "boolean" },
    enable_events = { cfg.enable_events, "boolean" },
  })

  if not ok then
    return false, "config: " .. err
  end

  ok, err = pcall(vim.validate, {
    show_full_paths = { cfg.ui.show_full_paths, "boolean" },
    show_preview = { cfg.ui.show_preview, "boolean" },
  })

  if not ok then
    return false, "config.ui: " .. err
  end

  return true
end

---Deep merge tables using vim.tbl_deep_extend
---@param t1 table
---@param t2 table
---@return table
local function merge(t1, t2)
  return vim.tbl_deep_extend("force", t1, t2)
end

---Setup the configuration
---@param opts table|nil
function M.setup(opts)
  if config then
    return
  end

  opts = opts or {}

  -- Support vim.g.worktrunk configuration
  if vim.g.worktrunk then
    opts = merge(opts, vim.g.worktrunk)
  end

  config = merge(defaults, opts)

  local ok, err = validate(config)
  if not ok then
    error(err)
  end
end

---Get the current configuration
---@return worktrunk.Config|nil
function M.get()
  return config
end

return M
