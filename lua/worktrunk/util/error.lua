---@module "worktrunk.util.error"
---Error handling utilities for worktrunk.nvim

local M = {}

---Error types
M.ERROR_TYPES = {
  BRANCH_NOT_FOUND = "branch_not_found",
  WORKTREE_EXISTS = "worktree_exists",
  DIRTY_WORKTREE = "dirty_worktree",
  CLI_NOT_FOUND = "cli_not_found",
  PARSE_ERROR = "parse_error",
  UNKNOWN = "unknown",
}

---Parse error from stderr output
---@param stderr string|nil
---@return string error_type
function M.parse_error(stderr)
  if not stderr then
    return M.ERROR_TYPES.UNKNOWN
  end

  if stderr:match("branch.*not found") then
    return M.ERROR_TYPES.BRANCH_NOT_FOUND
  elseif stderr:match("worktree already exists") then
    return M.ERROR_TYPES.WORKTREE_EXISTS
  elseif stderr:match("uncommitted changes") then
    return M.ERROR_TYPES.DIRTY_WORKTREE
  elseif stderr:match("command not found") or stderr:match("wt:") then
    return M.ERROR_TYPES.CLI_NOT_FOUND
  end

  return M.ERROR_TYPES.UNKNOWN
end

---Create a standardized error result
---@param ok boolean
---@param err string|nil
---@return boolean success
---@return string|nil error
function M.result(ok, err)
  return ok, err
end

---Check if result indicates success
---@param ok boolean
---@return boolean
function M.is_ok(ok)
  return ok == true
end

---Get error message for error type
---@param error_type string
---@param context string|nil
---@return string
function M.get_message(error_type, context)
  local messages = {
    [M.ERROR_TYPES.BRANCH_NOT_FOUND] = "Branch not found" .. (context and ": " .. context or ""),
    [M.ERROR_TYPES.WORKTREE_EXISTS] = "Worktree already exists" .. (context and ": " .. context or ""),
    [M.ERROR_TYPES.DIRTY_WORKTREE] = "Worktree has uncommitted changes",
    [M.ERROR_TYPES.CLI_NOT_FOUND] = "worktrunk CLI (wt) not found in PATH",
    [M.ERROR_TYPES.PARSE_ERROR] = "Failed to parse CLI output",
    [M.ERROR_TYPES.UNKNOWN] = "An unknown error occurred" .. (context and ": " .. context or ""),
  }

  return messages[error_type] or messages[M.ERROR_TYPES.UNKNOWN]
end

return M
