describe("worktrunk.commands", function()
  local commands
  local helpers = require("spec.helpers")
  local restore_ui

  before_each(function()
    package.loaded["worktrunk.commands"] = nil
    package.loaded["worktrunk.config"] = nil
    require("worktrunk.config").setup()
    commands = require("worktrunk.commands")
    restore_ui = helpers.mock_vim_ui()
  end)

  after_each(function()
    if restore_ui then
      restore_ui()
    end
  end)

  describe("complete", function()
    it("should complete subcommands", function()
      local completions = commands.complete("sw", "Worktree sw", 12)

      assert.is_table(completions)
      -- Check if "switch" is in completions
      local has_switch = false
      for _, v in ipairs(completions) do
        if v == "switch" then
          has_switch = true
          break
        end
      end
      assert.is_true(has_switch, "Expected 'switch' in completions, got: " .. vim.inspect(completions))
      
      -- Check if "list" is in completions (should not be, since it doesn't start with "sw")
      local has_list = false
      for _, v in ipairs(completions) do
        if v == "list" then
          has_list = true
          break
        end
      end
      assert.is_false(has_list, "Expected 'list' NOT in completions when arglead is 'sw'")
    end)

    it("should complete branch names for switch command", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
        { branch = "feature-branch", path = "/home/user/project.feature-branch" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local completions = commands.complete("", "Worktree switch ", 16)

      assert.is_table(completions)
      assert.is_true(vim.tbl_contains(completions, "main"))
      assert.is_true(vim.tbl_contains(completions, "feature-branch"))

      restore()
    end)

    it("should return empty table for unknown subcommand", function()
      local completions = commands.complete("", "Worktree unknown ", 18)

      assert.is_table(completions)
      assert.are.equal(0, #completions)
    end)
  end)

  describe("execute", function()
    it("should execute list subcommand", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      -- Should not throw
      local ok = pcall(function()
        commands.execute("list")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute switch subcommand with branch", function()
      local mock_result = {
        code = 0,
        stdout = "Switched to feature-branch",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("switch feature-branch")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should show error for unknown subcommand", function()
      local notified = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        notified = true
        assert.is_truthy(msg:match("Unknown subcommand"))
      end

      commands.execute("unknown")

      assert.is_true(notified)

      vim.notify = original_notify
    end)

    it("should default to list when no subcommand provided", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      -- Should not throw
      local ok = pcall(function()
        commands.execute("")
      end)

      assert.is_true(ok)

      restore()
    end)
  end)

  describe("parse_args", function()
    it("should parse switch args with options", function()
      local branch, opts = commands.parse_switch_args({ "--create", "new-branch" })

      assert.are.equal("new-branch", branch)
      assert.is_true(opts.create)
    end)

    it("should parse remove args with force option", function()
      local branch, opts = commands.parse_remove_args({ "--force", "old-branch" })

      assert.are.equal("old-branch", branch)
      assert.is_true(opts.force)
    end)

    it("should parse create args with base branch", function()
      local branch, base, opts = commands.parse_create_args({ "--base=main", "hotfix" })

      assert.are.equal("hotfix", branch)
      assert.are.equal("main", base)
    end)
  end)
end)
