describe("worktrunk.core", function()
  local core
  local helpers = require("spec.helpers")

  before_each(function()
    package.loaded["worktrunk.core"] = nil
    package.loaded["worktrunk.api.cli"] = nil
    package.loaded["worktrunk.config.internal"] = nil
    require("worktrunk.config.internal").setup()
    core = require("worktrunk.core")
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

    it("should identify dirty_worktree error", function()
      local stderr = "Error: worktree has uncommitted changes"
      local error_type = core.parse_error(stderr)

      assert.are.equal("dirty_worktree", error_type)
    end)

    it("should return unknown for unrecognized errors", function()
      local stderr = "Some random error message"
      local error_type = core.parse_error(stderr)

      assert.are.equal("unknown", error_type)
    end)

    it("should handle nil input", function()
      local error_type = core.parse_error(nil)
      assert.are.equal("unknown", error_type)
    end)
  end)

  describe("list", function()
    it("should call wt list command", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
        { branch = "feature", path = "/home/user/project.feature" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local worktrees = core.list()

      assert.are.equal(2, #worktrees)
      assert.are.equal("main", worktrees[1].branch)

      restore()
    end)

    it("should return empty table on error", function()
      local mock_result = {
        code = 1,
        stdout = "",
        stderr = "wt: command not found",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local worktrees = core.list()

      assert.are.equal(0, #worktrees)

      restore()
    end)
  end)

  describe("switch", function()
    it("should call wt switch command", function()
      local mock_result = {
        code = 0,
        stdout = "Switched to feature-branch",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.switch("feature-branch")

      assert.is_true(success)

      restore()
    end)

    it("should return false on error", function()
      local mock_result = {
        code = 1,
        stdout = "",
        stderr = "Error: branch 'nonexistent' not found",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.switch("nonexistent")

      assert.is_false(success)

      restore()
    end)
  end)

  describe("remove", function()
    it("should call wt remove command", function()
      local mock_result = {
        code = 0,
        stdout = "Removed worktree for old-branch",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.remove("old-branch")

      assert.is_true(success)

      restore()
    end)

    it("should support force option", function()
      local mock_result = {
        code = 0,
        stdout = "Removed worktree (forced) for dirty-branch",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.remove("dirty-branch", { force = true })

      assert.is_true(success)

      restore()
    end)
  end)

  describe("current", function()
    it("should return current worktree", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project", is_current = true },
        { branch = "feature", path = "/home/user/project.feature", is_current = false },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local current = core.current()

      assert.is_not_nil(current)
      assert.are.equal("main", current.branch)

      restore()
    end)

    it("should return nil if not in a worktree", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project", is_current = false },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local current = core.current()

      assert.is_nil(current)

      restore()
    end)
  end)

  describe("merge", function()
    it("should call wt merge command", function()
      local mock_result = {
        code = 0,
        stdout = "Merged feature-branch into main",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.merge("main")

      assert.is_true(success)

      restore()
    end)

    it("should support merge flags", function()
      local mock_result = {
        code = 0,
        stdout = "Merged with flags",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.merge("develop", {
        no_squash = true,
        no_ff = true,
        stage = "tracked",
      })

      assert.is_true(success)

      restore()
    end)

    it("should return false on error", function()
      local mock_result = {
        code = 1,
        stdout = "",
        stderr = "Merge failed: conflicts detected",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.merge("main")

      assert.is_false(success)

      restore()
    end)
  end)

  describe("step", function()
    it("should call wt step commit command", function()
      local mock_result = {
        code = 0,
        stdout = "Committed changes",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.step("commit", {})

      assert.is_true(success)

      restore()
    end)

    it("should call wt step squash command", function()
      local mock_result = {
        code = 0,
        stdout = "Squashed commits",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.step("squash", {})

      assert.is_true(success)

      restore()
    end)

    it("should support stage option", function()
      local mock_result = {
        code = 0,
        stdout = "Committed with stage=tracked",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.step("commit", { stage = "tracked" })

      assert.is_true(success)

      restore()
    end)

    it("should return false on error", function()
      local mock_result = {
        code = 1,
        stdout = "",
        stderr = "Step failed",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local success = core.step("commit", {})

      assert.is_false(success)

      restore()
    end)
  end)
end)
