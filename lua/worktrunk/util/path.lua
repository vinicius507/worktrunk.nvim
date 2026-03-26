---@module "worktrunk.util.path"
---Path utilities for worktrunk.nvim

local M = {}

---Expand path to absolute path
---@param path string
---@return string
function M.expand(path)
  return vim.fn.expand(path)
end

---Check if path is absolute
---@param path string
---@return boolean
function M.is_absolute(path)
  return vim.startswith(path, "/") or vim.startswith(path, "~")
end

---Get current working directory
---@return string
function M.cwd()
  return vim.fn.getcwd()
end

---Escape path for shell usage
---@param path string
---@return string
function M.escape(path)
  return vim.fn.fnameescape(path)
end

---Check if two paths are the same
---@param path1 string
---@param path2 string
---@return boolean
function M.equals(path1, path2)
  return vim.fn.resolve(path1) == vim.fn.resolve(path2)
end

return M
