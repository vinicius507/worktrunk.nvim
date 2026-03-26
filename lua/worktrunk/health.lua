---@module "worktrunk.health"
local M = {}

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
    vim.health.error("worktrunk CLI (wt) not found in PATH", { "Install from: https://worktrunk.dev" })
    return
  end

  local result = vim.system({ "wt", "--version" }):wait()
  if result.code ~= 0 then
    vim.health.warn("worktrunk CLI found but version check failed", { "Ensure wt is properly installed" })
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
    "wt_cmd",
    "auto_cd",
    "confirm_remove",
    "enable_events",
    "ui",
    "hooks",
    "pr",
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
