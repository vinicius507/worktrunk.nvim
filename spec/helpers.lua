local M = {}

function M.mock_vim_system(result)
  local original = vim.system
  vim.system = function(cmd, opts, callback)
    if callback then
      callback(result)
    end
    return {
      wait = function()
        return result
      end,
    }
  end
  return function()
    vim.system = original
  end
end

function M.mock_wt_list_output(worktrees)
  -- Return JSON format as expected by the CLI
  local stdout = vim.json.encode(worktrees)
  return {
    code = 0,
    stdout = stdout,
    stderr = "",
  }
end

function M.mock_vim_ui()
  local original_select = vim.ui.select
  local original_input = vim.ui.input
  local original_cmd = vim.cmd

  vim.ui.select = function(items, opts, on_choice)
    if #items > 0 then
      on_choice(items[1], 1)
    else
      on_choice(nil, nil)
    end
  end

  vim.ui.input = function(opts, on_confirm)
    on_confirm("test-branch")
  end

  vim.cmd = function(cmd)
    -- Mock vim.cmd to avoid errors from :tcd
  end

  return function()
    vim.ui.select = original_select
    vim.ui.input = original_input
    vim.cmd = original_cmd
  end
end

return M
